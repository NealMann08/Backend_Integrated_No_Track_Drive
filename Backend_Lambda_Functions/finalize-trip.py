# COMPLETE ENHANCED: finalize_trip.py - Fixed batch aggregation and trip analysis
import json
import boto3
from datetime import datetime, timezone
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
trips_table = dynamodb.Table('Trips-Neal')
trajectory_table = dynamodb.Table('TrajectoryBatches-Neal')

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

def parse_and_normalize_timestamp(timestamp_str):
    """
    CRITICAL FIX: Properly parse and normalize timestamps
    Converts various timestamp formats to consistent UTC ISO format
    """
    try:
        if not timestamp_str:
            return datetime.now(timezone.utc).isoformat()
        
        # Remove 'Z' suffix and replace with explicit UTC offset
        if timestamp_str.endswith('Z'):
            timestamp_str = timestamp_str[:-1] + '+00:00'
        
        # Parse the timestamp
        dt = datetime.fromisoformat(timestamp_str)
        
        # If no timezone info, assume it's UTC (from iPhone/frontend)
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        
        # Convert to UTC and return ISO format
        utc_dt = dt.astimezone(timezone.utc)
        return utc_dt.isoformat()
        
    except Exception as e:
        print(f"⚠️ Timestamp parsing error for '{timestamp_str}': {e}")
        # Fallback to current UTC time
        return datetime.now(timezone.utc).isoformat()

def calculate_accurate_duration(start_timestamp, end_timestamp):
    """Calculate accurate duration in minutes between two timestamps"""
    try:
        start_dt = datetime.fromisoformat(start_timestamp.replace('Z', '+00:00'))
        end_dt = datetime.fromisoformat(end_timestamp.replace('Z', '+00:00'))
        
        duration_seconds = (end_dt - start_dt).total_seconds()
        duration_minutes = max(1.0, duration_seconds / 60)  # Minimum 1 minute
        
        return duration_seconds, duration_minutes
    except Exception as e:
        print(f"⚠️ Duration calculation error: {e}")
        return 60.0, 1.0  # Fallback to 1 minute

def get_all_trip_batches(trip_id):
    """CRITICAL: Retrieve all batches for comprehensive trip analysis"""
    try:
        print(f"🔍 RETRIEVING ALL BATCHES for trip: {trip_id}")
        
        # Query all batches for this trip
        response = trajectory_table.scan(
            FilterExpression='trip_id = :trip_id',
            ExpressionAttributeValues={':trip_id': trip_id}
        )
        
        batches = response.get('Items', [])
        print(f"📊 Found {len(batches)} batches for trip {trip_id}")
        
        # Sort batches by batch number to ensure proper order
        batches.sort(key=lambda x: int(x.get('batch_number', 0)))
        
        # Aggregate all deltas from all batches
        all_deltas = []
        total_valid_deltas = 0
        total_original_deltas = 0
        batch_summary = []
        
        for batch in batches:
            batch_deltas = batch.get('deltas', [])
            batch_stats = batch.get('batch_statistics', {})
            
            all_deltas.extend(batch_deltas)
            total_valid_deltas += len(batch_deltas)
            total_original_deltas += int(batch.get('original_deltas_count', len(batch_deltas)))
            
            batch_info = {
                'batch_number': batch.get('batch_number'),
                'deltas_count': len(batch_deltas),
                'upload_timestamp': batch.get('upload_timestamp'),
                'movement_points': int(batch_stats.get('movement_points', 0)),
                'stationary_points': int(batch_stats.get('stationary_points', 0))
            }
            batch_summary.append(batch_info)
            
            print(f"   Batch {batch.get('batch_number')}: {len(batch_deltas)} deltas")
        
        print(f"📈 TOTAL AGGREGATED: {len(all_deltas)} deltas from {len(batches)} batches")
        
        return all_deltas, {
            'total_batches': len(batches),
            'total_valid_deltas': total_valid_deltas,
            'total_original_deltas': total_original_deltas,
            'acceptance_rate': (total_valid_deltas / total_original_deltas) if total_original_deltas > 0 else 0,
            'batch_summary': batch_summary,
            'movement_detected': any(batch.get('batch_statistics', {}).get('movement_points', 0) > 0 for batch in batches)
        }
        
    except Exception as e:
        print(f"❌ Error retrieving trip batches: {e}")
        return [], {'error': str(e)}

def analyze_trip_deltas(all_deltas):
    """ENHANCED: Comprehensive trip analysis from all delta coordinates"""
    if not all_deltas:
        print("⚠️ No deltas available for analysis")
        return {}
    
    print(f"🔬 ANALYZING {len(all_deltas)} deltas for trip patterns...")
    
    # Basic movement analysis
    movement_deltas = [d for d in all_deltas if not d.get('is_stationary', False)]
    stationary_deltas = [d for d in all_deltas if d.get('is_stationary', False)]
    
    # Speed analysis
    speed_data = [float(d.get('speed_mph', 0)) for d in all_deltas if d.get('speed_mph') is not None]
    
    # Time analysis
    time_intervals = [float(d.get('delta_time', 0)) for d in all_deltas if d.get('delta_time') is not None]
    
    # Coordinate movement analysis
    coordinate_movements = []
    for d in movement_deltas:
        lat_delta = abs(float(d.get('delta_lat', 0)))
        lon_delta = abs(float(d.get('delta_long', 0)))
        total_movement = (lat_delta ** 2 + lon_delta ** 2) ** 0.5
        coordinate_movements.append(total_movement)
    
    # Calculate analysis metrics
    analysis = {
        'total_deltas_analyzed': len(all_deltas),
        'movement_deltas': len(movement_deltas),
        'stationary_deltas': len(stationary_deltas),
        'movement_percentage': (len(movement_deltas) / len(all_deltas)) * 100 if all_deltas else 0,
        
        # Speed metrics
        'speed_points_available': len(speed_data),
        'average_speed_mph': sum(speed_data) / len(speed_data) if speed_data else 0,
        'max_speed_mph': max(speed_data) if speed_data else 0,
        'min_speed_mph': min(speed_data) if speed_data else 0,
        
        # Time metrics
        'average_time_interval': sum(time_intervals) / len(time_intervals) if time_intervals else 0,
        'total_time_seconds': sum(time_intervals),
        
        # Movement metrics
        'average_coordinate_movement': sum(coordinate_movements) / len(coordinate_movements) if coordinate_movements else 0,
        'max_coordinate_movement': max(coordinate_movements) if coordinate_movements else 0,
        'significant_movements': len([m for m in coordinate_movements if m > 0.00001]),  # > ~1 meter
        
        # Quality metrics
        'high_accuracy_deltas': len([d for d in all_deltas if d.get('gps_accuracy', 999) < 10]),
        'enhancement_scores': [float(d.get('enhancement_score', 0)) for d in all_deltas],
    }
    
    # Calculate overall quality score
    quality_factors = []
    if analysis['movement_percentage'] > 50:
        quality_factors.append(0.3)  # Good movement detection
    if analysis['speed_points_available'] > len(all_deltas) * 0.5:
        quality_factors.append(0.2)  # Good speed data availability
    if analysis['high_accuracy_deltas'] > len(all_deltas) * 0.7:
        quality_factors.append(0.3)  # Good GPS accuracy
    if analysis['significant_movements'] > 5:
        quality_factors.append(0.2)  # Sufficient movement detected
    
    analysis['overall_quality_score'] = sum(quality_factors)
    analysis['trip_validity'] = 'valid' if analysis['overall_quality_score'] > 0.6 else 'questionable'
    
    print(f"📊 ANALYSIS COMPLETE:")
    print(f"   Movement: {analysis['movement_percentage']:.1f}% ({analysis['movement_deltas']}/{analysis['total_deltas_analyzed']})")
    print(f"   Speed data: {analysis['speed_points_available']} points, avg: {analysis['average_speed_mph']:.1f} mph")
    print(f"   Quality score: {analysis['overall_quality_score']:.2f}")
    print(f"   Trip validity: {analysis['trip_validity']}")
    
    return analysis

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])
        
        user_id = body['user_id']
        trip_id = body['trip_id']
        end_timestamp_raw = body.get('end_timestamp')
        start_timestamp_raw = body.get('start_timestamp')
        trip_quality = body.get('trip_quality', {})
        
        print(f"🏁 ENHANCED TRIP FINALIZATION: {trip_id} for user: {user_id}")
        print(f"📱 Raw timestamps - Start: {start_timestamp_raw}, End: {end_timestamp_raw}")
        
        # CRITICAL FIX: Normalize timestamps properly
        end_timestamp = parse_and_normalize_timestamp(end_timestamp_raw)
        
        # Get existing trip data to find actual start time
        existing_trip = trips_table.get_item(Key={'trip_id': trip_id})
        
        if 'Item' not in existing_trip:
            print(f"⚠️ Trip {trip_id} not found in trips table, creating final record")
            
            # Use provided start timestamp or fallback to end timestamp
            start_timestamp = parse_and_normalize_timestamp(start_timestamp_raw) if start_timestamp_raw else end_timestamp
            
            trip_item = {
                'trip_id': trip_id,
                'user_id': user_id,
                'status': 'completed',
                'start_timestamp': start_timestamp,
                'end_timestamp': end_timestamp,
                'finalized_at': datetime.now(timezone.utc).isoformat(),
                'created_at': datetime.now(timezone.utc).isoformat(),
                'trip_quality': trip_quality,
                'total_batches': 0  # Will be updated below
            }
        else:
            # Update existing trip with proper timestamps
            existing_data = existing_trip['Item']
            
            # Use existing start timestamp (from first batch) or provided start timestamp
            if start_timestamp_raw:
                start_timestamp = parse_and_normalize_timestamp(start_timestamp_raw)
            else:
                start_timestamp = existing_data.get('start_timestamp', end_timestamp)
                # Ensure existing timestamp is also normalized
                start_timestamp = parse_and_normalize_timestamp(start_timestamp)
            
            trip_item = {
                'trip_id': trip_id,
                'user_id': user_id,
                'status': 'completed',
                'start_timestamp': start_timestamp,
                'end_timestamp': end_timestamp,
                'finalized_at': datetime.now(timezone.utc).isoformat(),
                'created_at': existing_data.get('created_at', datetime.now(timezone.utc).isoformat()),
                'total_batches': existing_data.get('total_batches', 0),
                'trip_quality': trip_quality
            }
        
        # CRITICAL: Get ALL batches for complete trip analysis
        all_deltas, batch_aggregation = get_all_trip_batches(trip_id)
        
        # Update trip with actual batch count
        trip_item['total_batches'] = batch_aggregation.get('total_batches', 0)
        
        # ENHANCED: Calculate accurate duration
        duration_seconds, duration_minutes = calculate_accurate_duration(trip_item['start_timestamp'], trip_item['end_timestamp'])
        
        # CRITICAL: Perform comprehensive trip analysis
        trip_analysis = analyze_trip_deltas(all_deltas)
        
        # Enhance trip quality with comprehensive analysis
        if isinstance(trip_quality, dict):
            trip_quality.update({
                # Timestamp and duration info
                'calculated_duration_seconds': duration_seconds,
                'calculated_duration_minutes': duration_minutes,
                'timestamp_source': 'iphone_gps' if start_timestamp_raw else 'server_calculated',
                'finalization_method': 'enhanced_v2_with_batch_aggregation',
                
                # Batch aggregation results
                'batch_aggregation': batch_aggregation,
                'trip_analysis': trip_analysis,
                
                # iPhone GPS integration (preserve existing metrics)
                'iphone_distance_miles': trip_quality.get('actual_distance_miles', 0),
                'iphone_gps_enabled': trip_quality.get('use_gps_metrics', False),
                
                # Enhanced validation
                'movement_validated': trip_analysis.get('movement_percentage', 0) > 20,  # At least 20% movement
                'sufficient_data': len(all_deltas) >= 5,  # At least 5 deltas
                'data_quality_score': trip_analysis.get('overall_quality_score', 0),
                'trip_validity_status': trip_analysis.get('trip_validity', 'unknown')
            })
            
            # Log comprehensive metrics
            if trip_quality.get('use_gps_metrics'):
                print(f"📱 iPhone GPS Metrics:")
                print(f"   Distance: {trip_quality.get('actual_distance_miles', 0):.3f} miles")
                print(f"   Duration: {trip_quality.get('actual_duration_minutes', 0):.1f} minutes")
                print(f"   Max Speed: {trip_quality.get('gps_max_speed_mph', 0):.1f} mph")
                print(f"   Avg Speed: {trip_quality.get('gps_avg_speed_mph', 0):.1f} mph")
            
            trip_item['trip_quality'] = trip_quality
        
        # Convert to DynamoDB format and store
        trip_item_dynamodb = convert_to_decimal(trip_item)
        trips_table.put_item(Item=trip_item_dynamodb)
        
        print(f"✅ ENHANCED TRIP FINALIZED: {trip_id}")
        print(f"📅 Duration: {duration_minutes:.1f} minutes ({duration_seconds:.0f} seconds)")
        print(f"📊 Batches processed: {batch_aggregation.get('total_batches', 0)}")
        print(f"📈 Total deltas analyzed: {len(all_deltas)}")
        print(f"🔧 iPhone GPS integration: {'Yes' if trip_quality.get('use_gps_metrics') else 'No'}")
        print(f"✅ Movement detected: {'Yes' if batch_aggregation.get('movement_detected') else 'No'}")
        print(f"🎯 Trip validity: {trip_analysis.get('trip_validity', 'unknown')}")
        
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST'
            },
            'body': json.dumps({
                'message': 'Trip finalized successfully with comprehensive analysis',
                'trip_id': trip_id,
                'start_timestamp': trip_item['start_timestamp'],
                'end_timestamp': trip_item['end_timestamp'],
                'duration_minutes': round(duration_minutes, 1),
                'duration_seconds': round(duration_seconds, 1),
                'total_batches': batch_aggregation.get('total_batches', 0),
                'total_deltas_analyzed': len(all_deltas),
                'movement_detected': batch_aggregation.get('movement_detected', False),
                'trip_validity': trip_analysis.get('trip_validity', 'unknown'),
                'data_quality_score': round(trip_analysis.get('overall_quality_score', 0), 2),
                'iphone_gps_enabled': trip_quality.get('use_gps_metrics', False),
                'batch_aggregation_summary': {
                    'total_batches': batch_aggregation.get('total_batches', 0),
                    'total_deltas': batch_aggregation.get('total_valid_deltas', 0),
                    'acceptance_rate': f"{batch_aggregation.get('acceptance_rate', 0) * 100:.1f}%"
                }
            })
        }
        
    except Exception as e:
        print(f"❌ ENHANCED FINALIZATION ERROR: {str(e)}")
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
                'error': 'Trip finalization failed',
                'details': str(e)
            })
        }