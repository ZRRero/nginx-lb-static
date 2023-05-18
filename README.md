# Instructions
## Install terraform
As prerequisites to execute this project you must have terraform installed, if you do not then execute the script called ``install-tf.sh``

## Execute the project
The project requires a DynamoDB table with it's primary key configured for Terraform and a S3 bucket for saving the states, those need to be configured in the ``config/backend.conf`` file for the project to work.

After the project is configured just execute the script ``execute-project.sh``

## About the cluster
The cluster is created using Nginx and works under a load balancer and static webpages, all the management is done using EC2 tagging, the tags for the static webpages are the following

- Owner: The name of the load balancer associated with the instance, this way you may have multiple load balancers with the same launch template, with this tag you may configure the instance that will manage the webpage
- Number: The number of the instance
- Weight: This tag determines the weight of the webpage instance in the load balancing, if set to 1 then the nginx will behave in round robin for this particular instance
- Bucket: This tag determines from which bucket the instance will get its configuration files, must be extracted from terraform output
- Name: Name of the instance

As for the load balancer instance the tags are the following

- Name: Name of the load balancer, directly tied to the Owner tag of the static instance, you may have as much load balancer instances as you like, as long as each name is distinct, this allows for multiple load balancers to work in the same account
- Bucket: This tag determines from which bucket the instance will get its configuration files, must be extracted from terraform output

## How to execute a cluster
Executing a cluster for the first time is as simple as running N instances for the static web pages and lastly an instance for the load balancer, an example of that would look like

```
aws ec2 run-instances \
--launch-template LaunchTemplateName="static_launch_template",Version="$Latest" \
--network-interfaces "[
{
\"SubnetId\": \"subnet-006e842954b9568db\",
\"DeviceIndex\": 0
}
]" \
--tag-specifications "ResourceType=instance,Tags=[{Key=Number,Value='1'},{Key=Bucket,Value='terraform-20230518015418894600000001'},{Key=Weight,Value='1'},{Key=Name,Value='Static-0'},{Key=Owner,Value='load_balancer'}]"
```

Execute that command changing values for the number of instances you desire, as for the load balancer command would go like

```
aws ec2 run-instances \
  --launch-template LaunchTemplateName="load_balancer_launch_template",Version="$Latest" \
  --network-interfaces "[
    {
      \"SubnetId\": \"subnet-006e842954b9568db\",
      \"DeviceIndex\": 0
    }
  ]" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value='load_balancer'},{Key=Bucket,Value='terraform-20230518015418894600000001'}]"
```
Take note this is an example and you will need to replace the values with the ones from terraform

## Checking health of the cluster
At any moment you may check the health of the instances by doing `curl <ip-address>/health`. Works for both the static webpages and the load balancer

## Updating the cluster
If you wish to add more instances to your cluster simply create them using the process above and execute the script "lb-update" located in the root of the load balancer instance, this script will recreate the configuration file for the load balancer, updating any new instances or deleted instances, this also works if you want to update the weights of your instances, simply change the Weight value in the desired instance and run the script.

## Adding new versions
As the configurations are managed using launch templates, a new version just requires to make the changes in terraform and execute, if you want to use a previous version replace the "$Latest" attribute with the version number in the commands 