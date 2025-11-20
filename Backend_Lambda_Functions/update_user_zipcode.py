# backend/update_user_zipcode.py - New Lambda function for updating user zipcode
import json
import boto3
from datetime import datetime
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
users_table = dynamodb.Table('Users-Neal')

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

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])
        user_id = body['user_id']
        zipcode = body['zipcode']
        base_point = body['base_point']
        privacy_settings = body.get('privacy_settings')

        print(f"Updating zipcode for user: {user_id} to {zipcode}")
        
        # Validate inputs
        if not user_id or not zipcode or not base_point:
            return {
                'statusCode': 400,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type',
                    'Access-Control-Allow-Methods': 'POST'
                },
                'body': json.dumps({'error': 'Missing required fields: user_id, zipcode, base_point'})
            }

        # Check if user exists
        response = users_table.get_item(Key={'user_id': user_id})
        if 'Item' not in response:
            return {
                'statusCode': 404,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type',
                    'Access-Control-Allow-Methods': 'POST'
                },
                'body': json.dumps({'error': 'User not found'})
            }

        # Validate base point
        validated_base_point = validate_base_point(base_point)
        if not validated_base_point:
            return {
                'statusCode': 400,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type',
                    'Access-Control-Allow-Methods': 'POST'
                },
                'body': json.dumps({'error': 'Invalid base point data'})
            }

        # Validate privacy settings
        validated_privacy = validate_privacy_settings(privacy_settings)

        # Update user record
        update_expression = 'SET zipcode = :zc, base_point = :bp, updated_at = :ua, data_version = :dv'
        expression_values = {
            ':zc': zipcode,
            ':bp': convert_to_decimal(validated_base_point),
            ':ua': datetime.utcnow().isoformat(),
            ':dv': '2.0'
        }

        if validated_privacy:
            update_expression += ', privacy_settings = :ps, privacy_level = :pl, anonymization_enabled = :ae'
            expression_values.update({
                ':ps': convert_to_decimal(validated_privacy),
                ':pl': validated_privacy['consentLevel'],
                ':ae': True
            })

        users_table.update_item(
            Key={'user_id': user_id},
            UpdateExpression=update_expression,
            ExpressionAttributeValues=expression_values
        )

        print(f"Successfully updated user {user_id} with new zipcode: {zipcode}")
        print(f"New base point: {validated_base_point['city']}, {validated_base_point['state']}")

        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST'
            },
            'body': json.dumps({
                'message': 'Zipcode and privacy settings updated successfully',
                'user_id': user_id,
                'zipcode': zipcode,
                'base_point_city': validated_base_point['city'],
                'base_point_state': validated_base_point['state'],
                'anonymization_enabled': True
            })
        }

    except KeyError as e:
        print(f"Missing required field: {str(e)}")
        return {
            'statusCode': 400,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST'
            },
            'body': json.dumps({'error': f'Missing required field: {str(e)}'})
        }

    except Exception as e:
        print(f"Error updating user zipcode: {str(e)}")
        import traceback
        traceback.print_exc()

        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST'
            },
            'body': json.dumps({'error': 'Internal server error'})
        }