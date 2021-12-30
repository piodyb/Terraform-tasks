Write a module which will create number of buckets corresponding do given list of maps, shaped like following example:

buckets = 
[ {
name = "somename"
encryption = True },
{
name = "someothername" encryption = False
} ]

Use the module to create a few buckets.
Uploading a file to a bucket should result in executing lambda function which will: 
* Get a random bucket (excluded the invoking one).
* Copy the uploaded file to it.
