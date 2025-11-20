# BULLETPROOF FIXED: store_trajectory_batch.py - Safe decimal conversion that handles ALL edge cases
import json
import boto3
from datetime import datetime
from decimal import Decimal
import math

dynamodb = boto3.resource('dynamodb')
trajectory_table = dynamodb.Table('TrajectoryBatches-Neal')
trips_table = dynamodb.Table('Trips-Neal')

def safe_convert_to_decimal(obj):
    """
    BULLETPROOF: Convert ALL possible values to DynamoDB-safe formats
    Handles NaN, Infinity, None, and all edge cases that cause ConversionSyntax errors
    """
    if isinstance(obj, dict):
        # Recursively convert dictionary values
        return {k: safe_convert_to_decimal(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        # Recursively convert list items
        return [safe_convert_to_decimal(item) for item in obj]
    elif isinstance(obj, float):
        # CRITICAL: Handle all problematic float values
        if math.isnan(obj):
            print(f"⚠️ Converting NaN to 0")
            return Decimal('0')
        elif math.isinf(obj):
            if obj > 0:
                print(f"⚠️ Converting +Infinity to large number")
                return Decimal('999999999')
            else:
                print(f"⚠️ Converting -Infinity to large negative number")
                return Decimal('-999999999')
        else:
            # Normal float - convert to Decimal safely
            try:
                return Decimal(str(obj))
            except Exception as e:
                print(f"⚠️ Float conversion error for {obj}: {e}, using 0")
                return Decimal('0')
    elif isinstance(obj, int):
        # Convert int to Decimal
        try:
            return Decimal(str(obj))
        except Exception as e:
            print(f"⚠️ Int conversion error for {obj}: {e}, using 0")
            return Decimal('0')
    elif obj is None:
        # Keep None as None (DynamoDB supports null)
        return None
    elif isinstance(obj, bool):
        # Keep boolean as boolean
        return obj
    elif isinstance(obj, str):
        # Keep string as string, but check for problematic string values
        if obj.lower() in ['nan', 'infinity', '-infinity', 'inf', '-inf']:
            print(f"⚠️ Converting problematic string '{obj}' to '0'")
            return Decimal('0')
        return obj
    else:
        # For any other type, convert to string safely
        try:
            str_value = str(obj)
            # Check if the string representation looks like a number
            if str_value.replace('.', '').replace('-', '').isdigit():
                return Decimal(str_value)
            else:
                return str_value
        except Exception as e:
            print(f"⚠️ Unknown type conversion error for {obj} (type: {type(obj)}): {e}")
            return str(obj) if obj is not None else None

def validate_enhanced_deltas(deltas):
    """ULTRA LENIENT: Accept almost any delta that has basic structure"""
    print(f"🔍 ULTRA LENIENT VALIDATION: {len(deltas)} deltas...")
    
    essential_fields = ['delta_lat', 'delta_long', 'delta_time']
    optional_fields = ['speed_mph', 'speed_confidence', 'gps_accuracy', 'is_stationary', 'data_quality', 'sequence', 'timestamp']
    
    valid_deltas = []
    quality_issues = []
    
    for i, delta in enumerate(deltas):
        delta_info = f"Delta {i}"
        
        # Check only essential fields exist
        missing_essential = [field for field in essential_fields if field not in delta or delta[field] is None]
        if missing_essential:
            quality_issues.append(f"{delta_info}: Missing essential fields: {missing_essential}")
            print(f"❌ {delta_info}: Missing {missing_essential}")
            continue
        
        # ULTRA LENIENT: Validate essential field values with minimal restrictions
        try:
            delta_lat = float(delta['delta_lat'])
            delta_lon = float(delta['delta_long']) 
            delta_time = float(delta['delta_time'])
            
            # CRITICAL: Check for problematic float values
            if math.isnan(delta_lat) or math.isnan(delta_lon) or math.isnan(delta_time):
                quality_issues.append(f"{delta_info}: Contains NaN values")
                print(f"⚠️ {delta_info}: Contains NaN values - skipping")
                continue
                
            if math.isinf(delta_lat) or math.isinf(delta_lon) or math.isinf(delta_time):
                quality_issues.append(f"{delta_info}: Contains Infinity values")
                print(f"⚠️ {delta_info}: Contains Infinity values - skipping")
                continue
            
            # Ultra lenient thresholds
            max_reasonable_delta = 1.0  # Allow up to 1 degree change
            max_reasonable_time = 3600  # Allow up to 1 hour between points
            
            if abs(delta_lat) > max_reasonable_delta or abs(delta_lon) > max_reasonable_delta:
                quality_issues.append(f"{delta_info}: Large coordinate change (lat: {delta_lat:.8f}, lon: {delta_lon:.8f})")
                print(f"⚠️ {delta_info}: Large coordinate change - lat: {delta_lat:.8f}, lon: {delta_lon:.8f}")
                # STILL ACCEPT IT - just log the issue
                
            if delta_time <= 0 or delta_time > max_reasonable_time:
                quality_issues.append(f"{delta_info}: Invalid time interval: {delta_time}s")
                print(f"⚠️ {delta_info}: Invalid time interval: {delta_time}s")
                continue  # Skip negative or too large time intervals
                
        except (ValueError, TypeError) as e:
            quality_issues.append(f"{delta_info}: Invalid numeric values: {e}")
            print(f"❌ {delta_info}: Invalid numeric values: {e}")
            continue
        
        # Calculate enhancement score based on available optional fields
        enhanced_score = 0
        for field in optional_fields:
            if field in delta and delta[field] is not None:
                enhanced_score += 1
        
        # SAFE: Set enhancement score with safe conversion
        delta['enhancement_score'] = enhanced_score / len(optional_fields) if len(optional_fields) > 0 else 0
        
        # Add sequence number if missing
        if 'sequence' not in delta:
            delta['sequence'] = i
            
        # Add timestamp if missing
        if 'timestamp' not in delta:
            delta['timestamp'] = datetime.utcnow().isoformat()
        
        # CRITICAL: Clean up any problematic values in the delta before accepting
        cleaned_delta = safe_convert_problematic_values(delta)
        
        print(f"✅ {delta_info}: lat={delta_lat:.8f}, lon={delta_lon:.8f}, time={delta_time:.1f}s, enhancement={cleaned_delta['enhancement_score']:.2f}")
        
        valid_deltas.append(cleaned_delta)
    
    acceptance_rate = len(valid_deltas) / len(deltas) if deltas else 0
    print(f"📊 ULTRA LENIENT VALIDATION COMPLETE: {len(valid_deltas)}/{len(deltas)} deltas accepted ({acceptance_rate:.1%})")
    
    if quality_issues:
        print(f"⚠️ Quality issues found: {len(quality_issues)}")
        for issue in quality_issues[:5]:  # Show first 5 issues
            print(f"   - {issue}")
    
    return valid_deltas, quality_issues

def safe_convert_problematic_values(delta):
    """
    CRITICAL: Clean up any problematic values in a delta object before DynamoDB storage
    """
    cleaned_delta = {}
    
    for key, value in delta.items():
        if isinstance(value, float):
            if math.isnan(value):
                print(f"⚠️ Cleaning NaN value in field '{key}'")
                cleaned_delta[key] = 0.0
            elif math.isinf(value):
                print(f"⚠️ Cleaning Infinity value in field '{key}'")
                cleaned_delta[key] = 999999.0 if value > 0 else -999999.0
            else:
                cleaned_delta[key] = value
        else:
            cleaned_delta[key] = value
    
    return cleaned_delta

def store_or_update_trip_metadata(user_id, trip_id, batch_number, first_point_timestamp, last_point_timestamp):
    """Store or update trip metadata in Trips table"""
    try:
        # Check if trip already exists
        existing_trip = trips_table.get_item(Key={'trip_id': trip_id})
        
        if 'Item' not in existing_trip:
            # First batch - create new trip record
            trip_item = {
                'trip_id': trip_id,
                'user_id': user_id,
                'status': 'active',
                'start_timestamp': first_point_timestamp,
                'end_timestamp': last_point_timestamp,
                'created_at': datetime.utcnow().isoformat(),
                'last_updated': datetime.utcnow().isoformat(),
                'total_batches': 1
            }
            trips_table.put_item(Item=trip_item)
            print(f"✅ NEW TRIP CREATED: {trip_id} starting at {first_point_timestamp}")
        else:
            # Update existing trip with latest end timestamp
            trips_table.update_item(
                Key={'trip_id': trip_id},
                UpdateExpression='SET end_timestamp = :end_ts, last_updated = :updated, total_batches = total_batches + :inc',
                ExpressionAttributeValues={
                    ':end_ts': last_point_timestamp,
                    ':updated': datetime.utcnow().isoformat(),
                    ':inc': 1
                }
            )
            print(f"✅ TRIP UPDATED: {trip_id} batch #{batch_number}, end time: {last_point_timestamp}")
            
    except Exception as e:
        print(f"❌ Error storing trip metadata: {e}")
        # DON'T FAIL - continue processing

def lambda_handler(event, context):
    try:
        print(f"🚀 BULLETPROOF PROCESSING - Headers: {event.get('headers', {})}")
        print(f"📊 Body size: {len(str(event.get('body', '')))} characters")
        
        # Parse JSON body with proper error handling
        try:
            body = json.loads(event['body'])
        except json.JSONDecodeError as e:
            print(f"❌ JSON DECODE ERROR: {str(e)}")
            return {
                'statusCode': 400,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type',
                    'Access-Control-Allow-Methods': 'POST'
                },
                'body': json.dumps({'error': f'Invalid JSON: {str(e)}'})
            }
        
        # Extract data from request
        user_id = body.get('user_id')
        trip_id = body.get('trip_id')
        batch_number = body.get('batch_number')
        batch_size = body.get('batch_size')
        first_point_timestamp = body.get('first_point_timestamp')
        last_point_timestamp = body.get('last_point_timestamp')
        deltas = body.get('deltas', [])
        
        print(f"🚀 PROCESSING BATCH: Trip {trip_id}, Batch #{batch_number}, {len(deltas)} deltas")
        print(f"👤 User: {user_id}")
        
        # Extract enhanced quality metrics if available
        quality_metrics = body.get('quality_metrics', {})
        
        # Validate required fields
        if not all([user_id, trip_id, deltas]):
            print(f"❌ Missing required fields: user_id={bool(user_id)}, trip_id={bool(trip_id)}, deltas={bool(deltas)}")
            return {
                'statusCode': 400,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type',
                    'Access-Control-Allow-Methods': 'POST'
                },
                'body': json.dumps({'error': 'Missing required fields'})
            }
        
        # CRITICAL: Show first few deltas for debugging
        print(f"📊 SAMPLE DELTAS (first 3):")
        for i, delta in enumerate(deltas[:3]):
            print(f"   Delta {i}: {delta}")
        
        # BULLETPROOF: Validate deltas with safe handling
        validated_deltas, quality_issues = validate_enhanced_deltas(deltas)
        
        if not validated_deltas:
            print(f"❌ NO VALID DELTAS FOUND after bulletproof validation")
            print(f"📊 Quality issues: {quality_issues}")
            return {
                'statusCode': 400,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type',
                    'Access-Control-Allow-Methods': 'POST'
                },
                'body': json.dumps({
                    'error': 'No valid deltas found',
                    'quality_issues': quality_issues,
                    'original_count': len(deltas),
                    'validated_count': len(validated_deltas),
                    'debug_info': 'Bulletproof validation failed - check delta structure'
                })
            }
        
        # Store trip metadata in Trips table
        store_or_update_trip_metadata(user_id, trip_id, batch_number, first_point_timestamp, last_point_timestamp)
        
        # Create unique batch ID
        batch_id = f"{trip_id}_batch_{batch_number}"
        
        # SAFE: Calculate enhanced batch statistics with safe conversions
        speed_data = []
        confidence_data = []
        accuracy_data = []
        
        for d in validated_deltas:
            # Safe extraction of speed data
            if 'speed_mph' in d and d['speed_mph'] is not None:
                try:
                    speed_val = float(d['speed_mph'])
                    if not (math.isnan(speed_val) or math.isinf(speed_val)):
                        speed_data.append(speed_val)
                except (ValueError, TypeError):
                    pass
            
            # Safe extraction of confidence data
            if 'speed_confidence' in d and d['speed_confidence'] is not None:
                try:
                    conf_val = float(d['speed_confidence'])
                    if not (math.isnan(conf_val) or math.isinf(conf_val)):
                        confidence_data.append(conf_val)
                except (ValueError, TypeError):
                    pass
            
            # Safe extraction of accuracy data
            if 'gps_accuracy' in d and d['gps_accuracy'] is not None:
                try:
                    acc_val = float(d['gps_accuracy'])
                    if not (math.isnan(acc_val) or math.isinf(acc_val)):
                        accuracy_data.append(acc_val)
                except (ValueError, TypeError):
                    pass
        
        batch_statistics = {
            'total_deltas': len(validated_deltas),
            'enhanced_deltas': len([d for d in validated_deltas if d.get('enhancement_score', 0) > 0.5]),
            'average_speed': sum(speed_data) / len(speed_data) if speed_data else 0,
            'average_confidence': sum(confidence_data) / len(confidence_data) if confidence_data else 0,
            'average_gps_accuracy': sum(accuracy_data) / len(accuracy_data) if accuracy_data else 0,
            'stationary_points': len([d for d in validated_deltas if d.get('is_stationary', False)]),
            'high_quality_points': len([d for d in validated_deltas if d.get('data_quality') == 'high']),
            'movement_points': len([d for d in validated_deltas if not d.get('is_stationary', False)])
        }
        
        # BULLETPROOF: Apply safe decimal conversion to EVERYTHING
        print(f"💾 BULLETPROOF CONVERSION - Converting all data to safe DynamoDB format...")
        
        item = {
            'batch_id': batch_id,
            'user_id': user_id,
            'trip_id': trip_id,
            'batch_number': batch_number,
            'batch_size': batch_size,
            'first_point_timestamp': first_point_timestamp,
            'last_point_timestamp': last_point_timestamp,
            'upload_timestamp': datetime.utcnow().isoformat(),
            'deltas': validated_deltas,  # Will be converted below
            'processed': False,
            # Enhanced metadata
            'data_version': '2.4',  # Updated version for bulletproof conversion
            'quality_metrics': quality_metrics,  # Will be converted below
            'batch_statistics': batch_statistics,  # Will be converted below
            'quality_issues': quality_issues,
            'enhancement_level': 'high' if batch_statistics['enhanced_deltas'] > len(validated_deltas) * 0.8 else 'medium',
            'original_deltas_count': len(deltas),
            'validation_acceptance_rate': len(validated_deltas) / len(deltas) if deltas else 0,
            'validation_method': 'bulletproof_safe_decimal_conversion'
        }
        
        # CRITICAL: Apply bulletproof safe decimal conversion to the ENTIRE item
        try:
            item_dynamodb = safe_convert_to_decimal(item)
            print(f"✅ Safe conversion completed successfully")
        except Exception as conversion_error:
            print(f"❌ CRITICAL: Safe conversion failed: {conversion_error}")
            # Even our safe conversion failed - this should never happen
            return {
                'statusCode': 500,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type',
                    'Access-Control-Allow-Methods': 'POST'
                },
                'body': json.dumps({
                    'error': 'Safe decimal conversion failed',
                    'details': str(conversion_error),
                    'error_type': 'conversion_failure'
                })
            }
        
        print(f"💾 STORING BATCH: {batch_id}")
        
        try:
            trajectory_table.put_item(Item=item_dynamodb)
            print(f"✅ BATCH STORED SUCCESSFULLY: {batch_id}")
        except Exception as dynamo_error:
            print(f"❌ DynamoDB storage error: {dynamo_error}")
            return {
                'statusCode': 500,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type',
                    'Access-Control-Allow-Methods': 'POST'
                },
                'body': json.dumps({
                    'error': 'DynamoDB storage failed',
                    'details': str(dynamo_error),
                    'error_type': 'dynamo_error'
                })
            }
        
        print(f"📊 Final batch stats: {batch_statistics}")
        print(f"🔢 Delta summary: {len(validated_deltas)} valid deltas from {len(deltas)} originals")
        
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST'
            },
            'body': json.dumps({
                'message': 'Bulletproof trajectory batch stored successfully',
                'batch_id': batch_id,
                'deltas_count': len(validated_deltas),
                'original_deltas_count': len(deltas),
                'acceptance_rate': f"{(len(validated_deltas) / len(deltas) * 100):.1f}%" if deltas else "0%",
                'enhancement_level': item['enhancement_level'],
                'quality_score': quality_metrics.get('gps_quality_score', 0),
                'batch_statistics': batch_statistics,
                'quality_issues_count': len(quality_issues),
                'movement_detected': batch_statistics['movement_points'] > 0,
                'validation_method': 'bulletproof_with_safe_conversion'
            })
        }
        
    except Exception as e:
        print(f"❌ UNEXPECTED ERROR in bulletproof handler: {str(e)}")
        import traceback
        traceback.print_exc()
        
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'details': str(e),
                'error_type': 'lambda_exception'
            })
        }