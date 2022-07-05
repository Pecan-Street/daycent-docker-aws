# daycent-docker-aws
A docker container to run DayCent and List100 using inputs/outputs from AWS S3

## Getting Started
### Setup
- Put your aws cli credentials into the `aws` directory. 
These will get inserted into your copy of the image when you build it to do transferes to and from S3. 
This will consist of two files:

  - `aws/config` : which will look something like this: 
    - ```
      [default]
      region = us-east-1
      output = json
      ```
  - `aws/credentials` : which will look something like this (secrets here have been changed, you will need to insert your own)
    - ```
      [default]
      aws_access_key_id = BLAHBLAHBLAHBLAHBLAH123
      aws_secret_access_key = mOreBlahbl4h81aHetcetcandSoon
      ```
- Add the `DayCent` and `list100` binaries into the `bin` directory. It expects them to have those exact names unless you want to go messing around with the `Dockerfile` and the `entrypoint.sh` files.

Setup should be done now.

### Building the image
- ```./build.sh``` will create an image called `daycent-cabbi:latest`
- You can also just run a command like `docker build . -t {whatevernameyoulike}`

### Running

This was built with the assumption that inputs would be downloaded from a compressed diretory stored on AWS S3, 
and also pushes outputs back there. It would be pretty simple to modify it to just work with a mounted volume into the 
running container's `/daycent` diretory though. Perhaps at some point I'll make that an option. Speaking of options:


#### Command Line Options:

There's a number of command line options available beyond the ones that come with DayCent and list100 to make this run:

- -s : schedule file name (without the .sch extension)
- -n : binary monthly file name (without the .bin extension)
- -m : if set, will download the binary monthly file from an s3 uri like s3://daycentinputs/inputs/monthly.bin
- -l : Non-Daycent parameter -l means we want to run list100 on it afterwards
- -e : extend file name, the binary file that will be read as a starting point (without the .bin extension)
- -f : if set will download the binary extend file from an s3 uri like s3://daycentinputs/inputs/extend.bin
- -i : s3 uri link to the s3 file containing the input directory that has been compressed into a .tgz, tar.gz, or zip file. (for example: s3://psitestdata/inputs/inputs.tgz)
- -j : job s3 bucket. a uri for an s3 bucket to collect the job inputs/outputs. will contain the individual runs from this job set (s3://daycent-jobs/jobs/1234)
- -r : run id (optional) : just a folder name to tack on to the job s3 uri to store job specific info. If not set, one will be created with the name `run12345678` where 123455678 is replaced with the epoch time in seconds.
- -o : copy entire run directory after the DayCent run to the s3 job/run/outputs directory (the directory gets created on the fly)

Putting this all together to run a simple case with no extend file set looks like:
`docker run -it daycent-cabbi:latest -s rainmore_eq -n rainmore_eq -l yes -i s3://my-daycent-jobs/jobs/myjob/input_data.tgz -j s3://my-daycent-jobs/jobs/myjob -r job1 -o yes`