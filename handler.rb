require 'aws-sdk-s3'
require 'json'

AMAZON_S3_CLIENT = Aws::S3::Client.new(region: 'us-east-1')

def hello(event:, context:)
    event = event['Records'].first
    bucket_name = event['s3']['bucket']['name']
    object_key_name = event['s3']['object']['key']
    object_name = object_key_name.split('/').last

    AMAZON_S3_CLIENT.get_object(bucket: bucket_name, key: object_key_name, response_target: "/tmp/#{object_name}")
    `/opt/ffmpeg/ffmpeg -i /tmp/#{object_name} -vcodec libx264 -pix_fmt yuv420p -profile:v baseline -level 3 -f mp4 /tmp/#{object_name.split('.').first}.mp4`
    AMAZON_S3_CLIENT.put_object(bucket: bucket_name, key: "compressed/#{object_name.split('.').first}.mp4", body: IO.read("/tmp/#{object_name.split('.').first}.mp4"))

    { statusCode: 200, body: JSON.generate('Function Ok!') }
end
