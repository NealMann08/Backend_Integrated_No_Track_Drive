# ENHANCED auth_user.py - Complete Account & Data Deletion
import json
import boto3
import hashlib
import secrets
import re
import uuid
from datetime import datetime
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
users_table = dynamodb.Table('Users-Neal')
trajectory_batches_table = dynamodb.Table('TrajectoryBatches-Neal')
trips_table = dynamodb.Table('Trips-Neal')

# Try to access additional tables (these might exist in your system)
try:
    summaries_table = dynamodb.Table('DrivingSummaries-Neal')
except:
    summaries_table = None

try:
    trip_summaries_table = dynamodb.Table('TripSummaries-Neal')
except:
    trip_summaries_table = None

def convert_to_decimal(obj):
    """Convert float values to Decimal for DynamoDB storage"""
    if isinstance(obj, dict):
        return {k: convert_to_decimal(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [convert_to_decimal(item) for item in obj]
    elif isinstance(obj, float):
        return Decimal(str(obj))
    else:
        return obj

def convert_decimal_to_float(obj):
    """Convert Decimal objects to float for JSON serialization"""
    if isinstance(obj, dict):
        return {k: convert_decimal_to_float(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [convert_decimal_to_float(item) for item in obj]
    elif isinstance(obj, Decimal):
        return float(obj)
    else:
        return obj

def validate_email(email):
    """Validate email format"""
    if not email:
        return False, "Email is required"
    
    # Comprehensive email regex
    email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    
    if not re.match(email_pattern, email):
        return False, "Please enter a valid email address"
    
    if len(email) > 254:  # RFC 5321 limit
        return False, "Email address is too long"
    
    return True, ""

def validate_password(password):
    """Validate password strength"""
    if not password:
        return False, "Password is required"
    
    if len(password) < 8:
        return False, "Password must be at least 8 characters long"
    
    if len(password) > 128:
        return False, "Password is too long (max 128 characters)"
    
    # Check for at least one letter and one number
    has_letter = re.search(r'[a-zA-Z]', password)
    has_number = re.search(r'\d', password)
    
    if not has_letter:
        return False, "Password must contain at least one letter"
    
    if not has_number:
        return False, "Password must contain at least one number"
    
    return True, ""

def hash_password(password):
    """
    FALLBACK: Hash password using PBKDF2 with SHA-256 (built into Python)
    This is secure and doesn't require external dependencies
    """
    try:
        # Generate a random salt
        salt = secrets.token_hex(32)  # 32 bytes = 64 hex characters
        
        # Use PBKDF2 with SHA-256 (100,000 iterations for security)
        pwdhash = hashlib.pbkdf2_hmac('sha256', 
                                      password.encode('utf-8'), 
                                      salt.encode('utf-8'), 
                                      100000)  # 100k iterations
        
        # Store salt + hash together
        stored_password = salt + pwdhash.hex()
        return stored_password
    except Exception as e:
        print(f"Error hashing password: {e}")
        return None

def verify_password(password, stored_password):
    """
    FALLBACK: Verify password against stored hash
    """
    try:
        if not stored_password or len(stored_password) < 64:
            return False
        
        # Extract salt (first 64 characters) and hash (rest)
        salt = stored_password[:64]
        stored_hash = stored_password[64:]
        
        # Hash the provided password with the same salt
        pwdhash = hashlib.pbkdf2_hmac('sha256',
                                      password.encode('utf-8'),
                                      salt.encode('utf-8'),
                                      100000)
        
        # Compare hashes securely
        return secrets.compare_digest(stored_hash, pwdhash.hex())
    except Exception as e:
        print(f"Error verifying password: {e}")
        return False

def check_email_exists(email):
    """Check if email already exists in database"""
    try:
        # Scan for email (consider creating GSI for better performance in production)
        response = users_table.scan(
            FilterExpression='email = :email',
            ExpressionAttributeValues={':email': email.lower()},
            ProjectionExpression='email'  # Only return email to minimize data transfer
        )
        return len(response['Items']) > 0
    except Exception as e:
        print(f"Error checking email existence: {e}")
        return False

def validate_privacy_settings(privacy_settings):
    """Validate privacy settings structure"""
    if not privacy_settings:
        return None
    
    try:
        validated = {
            'anonymizationRadius': privacy_settings.get('anonymizationRadius', 10),
            'dataRetentionPeriod': privacy_settings.get('dataRetentionPeriod', 12),
            'consentLevel': privacy_settings.get('consentLevel', 'full')
        }
        
        # Validate ranges
        validated['anonymizationRadius'] = max(1, min(50, validated['anonymizationRadius']))
        validated['dataRetentionPeriod'] = max(1, min(24, validated['dataRetentionPeriod']))
        
        if validated['consentLevel'] not in ['full', 'basic', 'minimal']:
            validated['consentLevel'] = 'full'
            
        return validated
    except Exception as e:
        print(f"Error validating privacy settings: {e}")
        return None

def validate_base_point(base_point):
    """Validate base point coordinates"""
    if not base_point:
        return None
        
    try:
        required_fields = ['latitude', 'longitude', 'city', 'state', 'source']
        if not all(field in base_point for field in required_fields):
            print(f"Base point missing required fields: {required_fields}")
            return None
            
        # Validate coordinate ranges
        lat = float(base_point['latitude'])
        lon = float(base_point['longitude'])
        
        if not (-90 <= lat <= 90) or not (-180 <= lon <= 180):
            print(f"Invalid coordinates: lat={lat}, lon={lon}")
            return None
            
        validated = {
            'latitude': lat,
            'longitude': lon,
            'city': str(base_point['city']),
            'state': str(base_point['state']),
            'source': str(base_point['source']),
            'zipcode': str(base_point.get('zipcode', '')),
            'cached_date': base_point.get('cached_date')
        }
        
        return validated
    except Exception as e:
        print(f"Error validating base point: {e}")
        return None

def delete_user_trip_data(user_id):
    """
    CRITICAL: Delete ALL user data from all tables
    This ensures complete account deletion and GDPR compliance
    """
    deletion_summary = {
        'trajectory_batches_deleted': 0,
        'trips_deleted': 0,
        'summaries_deleted': 0,
        'trip_summaries_deleted': 0,
        'errors': []
    }
    
    try:
        print(f"🗑️ Starting complete data deletion for user: {user_id}")
        
        # 1. Delete TrajectoryBatches (trip GPS data)
        try:
            print("🗑️ Deleting trajectory batches...")
            response = trajectory_batches_table.scan(
                FilterExpression='user_id = :user_id',
                ExpressionAttributeValues={':user_id': user_id},
                ProjectionExpression='batch_id, user_id'  # Only get keys for deletion
            )
            
            for item in response['Items']:
                trajectory_batches_table.delete_item(
                    Key={
                        'batch_id': item['batch_id']
                        # Add other key attributes if your table has composite keys
                    }
                )
                deletion_summary['trajectory_batches_deleted'] += 1
            
            print(f"✅ Deleted {deletion_summary['trajectory_batches_deleted']} trajectory batches")
            
        except Exception as e:
            error_msg = f"Error deleting trajectory batches: {e}"
            print(f"❌ {error_msg}")
            deletion_summary['errors'].append(error_msg)
        
        # 2. Delete Trips
        try:
            print("🗑️ Deleting trips...")
            response = trips_table.scan(
                FilterExpression='user_id = :user_id',
                ExpressionAttributeValues={':user_id': user_id},
                ProjectionExpression='trip_id, user_id'  # Only get keys for deletion
            )
            
            for item in response['Items']:
                trips_table.delete_item(
                    Key={
                        'trip_id': item['trip_id']
                        # Add other key attributes if your table has composite keys
                    }
                )
                deletion_summary['trips_deleted'] += 1
            
            print(f"✅ Deleted {deletion_summary['trips_deleted']} trips")
            
        except Exception as e:
            error_msg = f"Error deleting trips: {e}"
            print(f"❌ {error_msg}")
            deletion_summary['errors'].append(error_msg)
        
        # 3. Delete DrivingSummaries (if table exists)
        if summaries_table:
            try:
                print("🗑️ Deleting driving summaries...")
                response = summaries_table.scan(
                    FilterExpression='user_id = :user_id',
                    ExpressionAttributeValues={':user_id': user_id}
                )
                
                for item in response['Items']:
                    # Delete using the primary key (adjust based on your table schema)
                    summaries_table.delete_item(
                        Key={
                            'user_id': item['user_id'],
                            'summary_id': item.get('summary_id')  # Adjust based on your schema
                        }
                    )
                    deletion_summary['summaries_deleted'] += 1
                
                print(f"✅ Deleted {deletion_summary['summaries_deleted']} driving summaries")
                
            except Exception as e:
                error_msg = f"Error deleting driving summaries: {e}"
                print(f"❌ {error_msg}")
                deletion_summary['errors'].append(error_msg)
        
        # 4. Delete TripSummaries (if table exists)
        if trip_summaries_table:
            try:
                print("🗑️ Deleting trip summaries...")
                response = trip_summaries_table.scan(
                    FilterExpression='user_id = :user_id',
                    ExpressionAttributeValues={':user_id': user_id}
                )
                
                for item in response['Items']:
                    trip_summaries_table.delete_item(
                        Key={
                            'trip_id': item['trip_id']  # Adjust based on your schema
                        }
                    )
                    deletion_summary['trip_summaries_deleted'] += 1
                
                print(f"✅ Deleted {deletion_summary['trip_summaries_deleted']} trip summaries")
                
            except Exception as e:
                error_msg = f"Error deleting trip summaries: {e}"
                print(f"❌ {error_msg}")
                deletion_summary['errors'].append(error_msg)
        
        total_deleted = (deletion_summary['trajectory_batches_deleted'] + 
                        deletion_summary['trips_deleted'] + 
                        deletion_summary['summaries_deleted'] + 
                        deletion_summary['trip_summaries_deleted'])
        
        print(f"🎯 DATA DELETION COMPLETE:")
        print(f"   Total items deleted: {total_deleted}")
        print(f"   Trajectory batches: {deletion_summary['trajectory_batches_deleted']}")
        print(f"   Trips: {deletion_summary['trips_deleted']}")
        print(f"   Driving summaries: {deletion_summary['summaries_deleted']}")
        print(f"   Trip summaries: {deletion_summary['trip_summaries_deleted']}")
        print(f"   Errors: {len(deletion_summary['errors'])}")
        
        return deletion_summary
        
    except Exception as e:
        error_msg = f"Critical error in data deletion: {e}"
        print(f"❌ {error_msg}")
        deletion_summary['errors'].append(error_msg)
        return deletion_summary

def create_error_response(status_code, message):
    """Create standardized error response"""
    return {
        'statusCode': status_code,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'POST, DELETE'
        },
        'body': json.dumps({'error': message})
    }

def create_success_response(data):
    """Create standardized success response"""
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'POST, DELETE'
        },
        'body': json.dumps(data)
    }

def handle_signup(body):
    """Handle user signup with email/password"""
    try:
        print("🔐 SIGNUP: Starting user registration")
        
        # Extract and validate required fields
        email = body.get('email', '').strip().lower()
        password = body.get('password', '')
        name = body.get('name', '').strip()
        role = body.get('role', '')
        
        print(f"📧 Signup attempt for email: {email}")
        
        # Validate required fields
        if not email or not password or not name or not role:
            print("❌ Missing required fields")
            return create_error_response(400, 'Email, password, name, and role are required')
        
        # Validate email
        email_valid, email_error = validate_email(email)
        if not email_valid:
            print(f"❌ Invalid email: {email_error}")
            return create_error_response(400, email_error)
        
        # Validate password
        password_valid, password_error = validate_password(password)
        if not password_valid:
            print(f"❌ Invalid password: {password_error}")
            return create_error_response(400, password_error)
        
        # Validate role
        if role not in ['driver', 'provider', 'admin']:
            print(f"❌ Invalid role: {role}")
            return create_error_response(400, 'Role must be either "driver", "provider", or "admin"')
        
        # Check if email already exists (early check to prevent processing)
        if check_email_exists(email):
            print(f"❌ Email already exists: {email}")
            return create_error_response(409, 'An account with this email already exists. Please sign in instead.')
        
        # Generate unique user ID
        user_id = str(uuid.uuid4())
        print(f"🆔 Generated user ID: {user_id}")
        
        # Hash password
        hashed_password = hash_password(password)
        if not hashed_password:
            print("❌ Failed to hash password")
            return create_error_response(500, 'Failed to secure password')
        
        print("🔒 Password hashed successfully")
        
        # Prepare user data
        user_data = {
            'user_id': user_id,
            'email': email,
            'password_hash': hashed_password,
            'name': name,
            'role': role,
            'created_at': datetime.utcnow().isoformat(),
            'last_login': datetime.utcnow().isoformat(),
            'account_status': 'active',
            'data_version': '4.0_enhanced_deletion'
        }
        
        # Add driver-specific fields
        if role == 'driver':
            print("👤 Processing driver-specific data")
            zipcode = body.get('zipcode', '').strip()
            base_point = body.get('base_point')
            privacy_settings = body.get('privacy_settings')
            
            if zipcode:
                user_data['zipcode'] = zipcode
                print(f"📍 Zipcode: {zipcode}")
            
            validated_base_point = validate_base_point(base_point)
            if validated_base_point:
                user_data['base_point'] = validated_base_point
                print(f"🎯 Base point: {validated_base_point['city']}, {validated_base_point['state']}")
            
            validated_privacy = validate_privacy_settings(privacy_settings)
            if validated_privacy:
                user_data['privacy_settings'] = validated_privacy
                print(f"🛡️ Privacy settings applied")
            
            # Driver-specific metadata
            user_data['anonymization_enabled'] = bool(validated_base_point)
            user_data['privacy_level'] = validated_privacy.get('consentLevel', 'full') if validated_privacy else 'full'

        # Add admin-specific fields
        elif role == 'admin':
            print("👑 Processing admin-specific data")

            # Extract admin-specific fields from metadata
            metadata = body.get('metadata')
            if metadata:
                try:
                    # If metadata is a JSON string, parse it
                    if isinstance(metadata, str):
                        import json
                        admin_metadata = json.loads(metadata)
                    else:
                        admin_metadata = metadata

                    # Store admin metadata
                    user_data['metadata'] = admin_metadata
                    print(f"📎 Admin metadata: {admin_metadata.get('admin_id', 'N/A')}")

                    # Set first_login flag for password change prompt
                    if 'first_login' not in admin_metadata:
                        admin_metadata['first_login'] = True
                        user_data['metadata'] = admin_metadata

                except Exception as e:
                    print(f"⚠️ Error parsing admin metadata: {e}")
                    user_data['metadata'] = {'first_login': True}
            else:
                # Default metadata for admin if none provided
                user_data['metadata'] = {'first_login': True}

        # Add provider-specific fields
        elif role == 'provider':
            print("🏢 Processing provider (ISP) specific data")

            # Store provider metadata if provided
            metadata = body.get('metadata')
            if metadata:
                try:
                    if isinstance(metadata, str):
                        import json
                        provider_metadata = json.loads(metadata)
                    else:
                        provider_metadata = metadata

                    user_data['metadata'] = provider_metadata
                    print(f"📎 Provider metadata: {provider_metadata.get('state', 'N/A')}")
                except Exception as e:
                    print(f"⚠️ Error parsing provider metadata: {e}")

        # (remove if not working asap) Store any additional metadata from Flutter app
        # This is now handled above per role, but keeping for backward compatibility
        if 'metadata' not in user_data:
            metadata = body.get('metadata')
            if metadata and isinstance(metadata, dict):
                user_data['metadata'] = metadata
                print(f"📎 Storing additional metadata: {list(metadata.keys())}")

        # Store user in database
        print("💾 Storing user in database")
        dynamodb_user_data = convert_to_decimal(user_data)
        users_table.put_item(Item=dynamodb_user_data)
        
        print(f"✅ User created successfully: {email}")
        
        # Return user data (without password hash)
        safe_user_data = {k: v for k, v in user_data.items() if k != 'password_hash'}
        
        return create_success_response({
            'message': 'Account created successfully',
            'user_data': safe_user_data
        })
        
    except Exception as e:
        print(f"❌ Signup error: {str(e)}")
        import traceback
        traceback.print_exc()
        return create_error_response(500, 'Account creation failed')

def handle_signin(body):
    """Handle user signin with email/password"""
    try:
        print("🔐 SIGNIN: Starting user authentication")
        
        # Extract and validate required fields
        email = body.get('email', '').strip().lower()
        password = body.get('password', '')
        
        print(f"📧 Signin attempt for email: {email}")
        
        if not email or not password:
            print("❌ Missing email or password")
            return create_error_response(400, 'Email and password are required')
        
        # Validate email format
        email_valid, email_error = validate_email(email)
        if not email_valid:
            print(f"❌ Invalid email format: {email_error}")
            return create_error_response(400, email_error)
        
        # Find user by email
        print("🔍 Looking up user by email")
        response = users_table.scan(
            FilterExpression='email = :email',
            ExpressionAttributeValues={':email': email}
        )
        
        if not response['Items']:
            print(f"❌ User not found: {email}")
            return create_error_response(401, 'Invalid email or password')
        
        user_data = response['Items'][0]
        print(f"✅ User found: {email}")
        
        # Check account status
        if user_data.get('account_status') != 'active':
            print(f"❌ Account inactive: {email}")
            return create_error_response(401, 'Account is inactive')
        
        # Verify password
        stored_hash = user_data.get('password_hash')
        if not stored_hash or not verify_password(password, stored_hash):
            print(f"❌ Invalid password: {email}")
            return create_error_response(401, 'Invalid email or password')
        
        print("🔒 Password verified successfully")
        
        # Update last login
        try:
            users_table.update_item(
                Key={'user_id': user_data['user_id']},
                UpdateExpression='SET last_login = :timestamp',
                ExpressionAttributeValues={':timestamp': datetime.utcnow().isoformat()}
            )
            print("📅 Last login updated")
        except Exception as e:
            print(f"⚠️ Could not update last login: {e}")
        
        # Return user data (without password hash)
        clean_user_data = convert_decimal_to_float(user_data)
        safe_user_data = {k: v for k, v in clean_user_data.items() if k != 'password_hash'}
        
        print(f"✅ Signin successful: {email}")
        
        return create_success_response({
            'message': 'Login successful',
            'user_data': safe_user_data
        })
        
    except Exception as e:
        print(f"❌ Signin error: {str(e)}")
        import traceback
        traceback.print_exc()
        return create_error_response(500, 'Login failed')

def handle_change_password(body):
    """
    Handle password change with current password verification
    """
    try:
        print("🔐 CHANGE PASSWORD: Starting password change")

        # Extract required fields
        email = body.get('email', '').strip().lower()
        current_password = body.get('current_password', '')
        new_password = body.get('new_password', '')

        print(f"📧 Password change request for: {email}")

        # Validate required fields
        if not email or not current_password or not new_password:
            print("❌ Missing required fields")
            return create_error_response(400, 'Email, current password, and new password are required')

        # Validate email format
        email_valid, email_error = validate_email(email)
        if not email_valid:
            print(f"❌ Invalid email: {email_error}")
            return create_error_response(400, email_error)

        # Validate new password strength
        password_valid, password_error = validate_password(new_password)
        if not password_valid:
            print(f"❌ New password invalid: {password_error}")
            return create_error_response(400, password_error)

        # Check that new password is different from current
        if current_password == new_password:
            print("❌ New password same as current")
            return create_error_response(400, 'New password must be different from current password')

        # Find user by email
        print("🔍 Looking up user by email")
        response = users_table.scan(
            FilterExpression='email = :email',
            ExpressionAttributeValues={':email': email}
        )

        if not response['Items']:
            print(f"❌ User not found: {email}")
            return create_error_response(404, 'User not found')

        user_data = response['Items'][0]
        user_id = user_data['user_id']
        print(f"✅ User found: {email}")

        # Check account status
        if user_data.get('account_status') != 'active':
            print(f"❌ Account inactive: {email}")
            return create_error_response(401, 'Account is inactive')

        # Verify current password
        stored_hash = user_data.get('password_hash')
        if not stored_hash or not verify_password(current_password, stored_hash):
            print(f"❌ Current password incorrect: {email}")
            return create_error_response(401, 'Current password is incorrect')

        print("🔒 Current password verified")

        # Hash new password
        new_hashed_password = hash_password(new_password)
        if not new_hashed_password:
            print("❌ Failed to hash new password")
            return create_error_response(500, 'Failed to secure new password')

        # Update password in database
        print("💾 Updating password in database")
        users_table.update_item(
            Key={'user_id': user_id},
            UpdateExpression='SET password_hash = :pwd, password_updated_at = :timestamp',
            ExpressionAttributeValues={
                ':pwd': new_hashed_password,
                ':timestamp': datetime.utcnow().isoformat()
            }
        )

        print(f"✅ Password changed successfully for: {email}")

        return create_success_response({
            'message': 'Password changed successfully'
        })

    except Exception as e:
        print(f"❌ Change password error: {str(e)}")
        import traceback
        traceback.print_exc()
        return create_error_response(500, 'Password change failed')

def handle_delete_account(body):
    """
    ENHANCED: Handle complete account deletion with full data cleanup
    """
    try:
        print("🗑️ DELETE: Starting complete account deletion")
        
        # Extract and validate required fields
        email = body.get('email', '').strip().lower()
        password = body.get('password', '')
        user_id = body.get('user_id', '')  # Optional: for direct user_id deletion
        
        print(f"📧 Delete account request for: {email}")
        
        if not email or not password:
            print("❌ Missing email or password")
            return create_error_response(400, 'Email and password are required to delete account')
        
        # Find user by email
        print("🔍 Looking up user for deletion")
        response = users_table.scan(
            FilterExpression='email = :email',
            ExpressionAttributeValues={':email': email}
        )
        
        if not response['Items']:
            print(f"❌ Account not found: {email}")
            return create_error_response(404, 'Account not found')
        
        user_data = response['Items'][0]
        found_user_id = user_data['user_id']
        
        # Security check: if user_id provided, make sure it matches
        if user_id and user_id != found_user_id:
            print(f"❌ User ID mismatch for deletion: {email}")
            return create_error_response(403, 'User ID mismatch')
        
        # Verify password before deletion
        stored_hash = user_data.get('password_hash')
        if not stored_hash or not verify_password(password, stored_hash):
            print(f"❌ Invalid password for deletion: {email}")
            return create_error_response(401, 'Invalid password')
        
        print("🔒 Password verified for deletion")
        
        # CRITICAL: Delete ALL user data from all tables
        deletion_summary = delete_user_trip_data(found_user_id)
        
        # Finally, delete the user account itself
        print("🗑️ Deleting user account...")
        users_table.delete_item(Key={'user_id': found_user_id})
        
        print(f"✅ COMPLETE ACCOUNT DELETION SUCCESSFUL: {email}")
        print(f"🎯 Data deleted from all tables:")
        print(f"   - User account: DELETED")
        print(f"   - Trajectory batches: {deletion_summary['trajectory_batches_deleted']}")
        print(f"   - Trips: {deletion_summary['trips_deleted']}")
        print(f"   - Summaries: {deletion_summary['summaries_deleted']}")
        print(f"   - Trip summaries: {deletion_summary['trip_summaries_deleted']}")
        
        response_data = {
            'message': 'Account and all associated data deleted successfully',
            'deletion_summary': {
                'user_account_deleted': True,
                'trajectory_batches_deleted': deletion_summary['trajectory_batches_deleted'],
                'trips_deleted': deletion_summary['trips_deleted'],
                'summaries_deleted': deletion_summary['summaries_deleted'],
                'trip_summaries_deleted': deletion_summary['trip_summaries_deleted'],
                'total_items_deleted': (deletion_summary['trajectory_batches_deleted'] + 
                                      deletion_summary['trips_deleted'] + 
                                      deletion_summary['summaries_deleted'] + 
                                      deletion_summary['trip_summaries_deleted'] + 1),  # +1 for user account
                'errors': deletion_summary['errors']
            }
        }
        
        return create_success_response(response_data)
        
    except Exception as e:
        print(f"❌ Account deletion error: {str(e)}")
        import traceback
        traceback.print_exc()
        return create_error_response(500, 'Account deletion failed')

def handle_admin_stats(body):
    """Return user counts by role and recent signups for admin dashboard"""
    try:
        print("📊 ADMIN_STATS: Fetching user statistics")

        response = users_table.scan(
            ProjectionExpression='user_id, email, #n, #r, created_at',
            ExpressionAttributeNames={'#n': 'name', '#r': 'role'}
        )

        items = response['Items']
        # Handle pagination
        while 'LastEvaluatedKey' in response:
            response = users_table.scan(
                ProjectionExpression='user_id, email, #n, #r, created_at',
                ExpressionAttributeNames={'#n': 'name', '#r': 'role'},
                ExclusiveStartKey=response['LastEvaluatedKey']
            )
            items.extend(response['Items'])

        # Count by role
        drivers = [u for u in items if u.get('role') == 'driver']
        admins = [u for u in items if u.get('role') == 'admin']
        providers = [u for u in items if u.get('role') == 'provider']

        # Get recent signups sorted by created_at (most recent first)
        sorted_users = sorted(items, key=lambda u: u.get('created_at', ''), reverse=True)
        recent_signups = []
        for u in sorted_users[:10]:
            recent_signups.append({
                'email': u.get('email', ''),
                'name': u.get('name', ''),
                'role': u.get('role', ''),
                'created_at': u.get('created_at', '')
            })

        stats = {
            'total_users': len(drivers),
            'total_admins': len(admins),
            'total_insurance': len(providers),
            'total_all': len(items),
            'role_breakdown': {
                'drivers': len(drivers),
                'admins': len(admins),
                'providers': len(providers)
            },
            'recent_signups': recent_signups
        }

        print(f"✅ Stats: {len(drivers)} drivers, {len(admins)} admins, {len(providers)} providers")
        return create_success_response(convert_decimal_to_float(stats))

    except Exception as e:
        print(f"❌ Admin stats error: {str(e)}")
        import traceback
        traceback.print_exc()
        return create_error_response(500, 'Failed to fetch admin stats')

def handle_health_check(body):
    """Quick DynamoDB connectivity test for server status"""
    try:
        print("🏥 HEALTH_CHECK: Testing DynamoDB connectivity")
        # Quick read to verify DynamoDB is reachable
        users_table.scan(Limit=1, ProjectionExpression='user_id')
        print("✅ Health check passed")
        return create_success_response({'status': 'healthy'})
    except Exception as e:
        print(f"❌ Health check failed: {str(e)}")
        return create_error_response(500, 'Health check failed')

def handle_search_users(body):
    """Search users by email with optional role filter"""
    try:
        query = body.get('query', '').strip().lower()
        role_filter = body.get('role_filter', '')

        print(f"🔍 SEARCH_USERS: query='{query}', role_filter='{role_filter}'")

        if not query:
            return create_error_response(400, 'Search query is required')

        # Build filter expression
        filter_expr = 'contains(email, :query)'
        expr_values = {':query': query}

        if role_filter:
            filter_expr += ' AND #r = :role'
            expr_values[':role'] = role_filter

        scan_kwargs = {
            'FilterExpression': filter_expr,
            'ExpressionAttributeValues': expr_values,
            'ProjectionExpression': 'user_id, email, #n, #r, created_at, account_status, metadata'
        }

        # Add ExpressionAttributeNames (role and name are reserved words)
        expr_names = {'#n': 'name', '#r': 'role'}
        scan_kwargs['ExpressionAttributeNames'] = expr_names

        response = users_table.scan(**scan_kwargs)
        items = response['Items']

        # Handle pagination
        while 'LastEvaluatedKey' in response:
            scan_kwargs['ExclusiveStartKey'] = response['LastEvaluatedKey']
            response = users_table.scan(**scan_kwargs)
            items.extend(response['Items'])

        # Format results
        users = []
        for u in items:
            name_parts = (u.get('name', '') or '').split(' ', 1)
            user_entry = {
                'user_id': u.get('user_id', ''),
                'email': u.get('email', ''),
                'first_name': name_parts[0] if name_parts else '',
                'last_name': name_parts[1] if len(name_parts) > 1 else '',
                'role': u.get('role', ''),
                'created_at': u.get('created_at', ''),
                'account_status': u.get('account_status', ''),
            }
            # Include metadata for providers
            if u.get('metadata'):
                user_entry['metadata'] = u['metadata']
            users.append(user_entry)

        print(f"✅ Found {len(users)} users matching query")
        return create_success_response({
            'users': convert_decimal_to_float(users),
            'count': len(users)
        })

    except Exception as e:
        print(f"❌ Search users error: {str(e)}")
        import traceback
        traceback.print_exc()
        return create_error_response(500, 'Search failed')

def lambda_handler(event, context):
    """
    ENHANCED Lambda handler for email/password authentication with complete data deletion
    Supports: signup, signin, change_password, delete_account
    """
    try:
        print(f"🚀 Enhanced Auth Lambda invoked: {event.get('httpMethod', 'Unknown')} {event.get('path', 'Unknown')}")
        
        # Handle CORS preflight requests
        if event.get('httpMethod') == 'OPTIONS':
            print("✅ CORS preflight request")
            return {
                'statusCode': 200,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type',
                    'Access-Control-Allow-Methods': 'POST, DELETE'
                },
                'body': ''
            }
        
        # Parse request body
        try:
            body = json.loads(event['body'])
            print(f"📝 Request body parsed successfully : {body}")
        except (json.JSONDecodeError, TypeError) as e:
            print(f"❌ Invalid JSON: {e}")
            return create_error_response(400, 'Invalid JSON in request body')
        
        # Get the mode/action
        mode = body.get('mode', '').lower()
        print(f"🎯 Request mode: {mode}")
        
        if not mode:
            print("❌ Missing mode")
            return create_error_response(400, 'Mode is required (signup, signin, change_password, or delete_account)')
        
        # Route to appropriate handler
        if mode == 'signup':
            return handle_signup(body)
        elif mode == 'signin':
            return handle_signin(body)
        elif mode == 'change_password':
            return handle_change_password(body)
        elif mode == 'delete_account':
            return handle_delete_account(body)
        elif mode == 'admin_stats':
            return handle_admin_stats(body)
        elif mode == 'health_check':
            return handle_health_check(body)
        elif mode == 'search_users':
            return handle_search_users(body)
        else:
            print(f"❌ Invalid mode: {mode}")
            return create_error_response(400, 'Invalid mode. Must be signup, signin, change_password, delete_account, admin_stats, health_check, or search_users')
    
    except Exception as e:
        print(f"❌ Lambda handler error: {str(e)}")
        import traceback
        traceback.print_exc()
        return create_error_response(500, 'Internal server error')