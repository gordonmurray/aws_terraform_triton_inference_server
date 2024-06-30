# Using Packer, Ansible and Terraform to create a small Triton Inference cluster



## Intro

* Using Ubuntu 22.04 LTS as a base - Ubuntu 24.04 worked in some brief testing but doesn't seem to be [supported yet](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/supported-platforms.html)
* Using a G5.xlarge instance - G6's would be lower cost but are only [available in in US East (N. Virginia and Ohio) and US West (Oregon) regions so far](https://aws.amazon.com/about-aws/whats-new/2024/04/general-availability-amazon-ec2-g6-instances/)
* Not using Graviton instances (G5g), The T4G GPUs used in G5g instances are less powerful than those in other GPU instance types.

The log from the Docker container once Triton has started up:
```
I0630 09:01:04.101097 1 metrics.cc:864] Collecting metrics for GPU 0: NVIDIA A10G
I0630 09:01:04.101779 1 metrics.cc:757] Collecting CPU metrics
I0630 09:01:04.102062 1 tritonserver.cc:2264]
+----------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------+
| Option                           | Value                                                                                                                                            |
+----------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------+
| server_id                        | triton                                                                                                                                           |
| server_version                   | 2.29.0                                                                                                                                           |
| server_extensions                | classification sequence model_repository model_repository(unload_dependents) schedule_policy model_configuration system_shared_memory cuda_share |
|                                  | d_memory binary_tensor_data statistics trace logging                                                                                             |
| model_repository_path[0]         | /models                                                                                                                                          |
| model_control_mode               | MODE_NONE                                                                                                                                        |
| strict_model_config              | 0                                                                                                                                                |
| rate_limit                       | OFF                                                                                                                                              |
| pinned_memory_pool_byte_size     | 268435456                                                                                                                                        |
| cuda_memory_pool_byte_size{0}    | 67108864                                                                                                                                         |
| response_cache_byte_size         | 0                                                                                                                                                |
| min_supported_compute_capability | 6.0                                                                                                                                              |
| strict_readiness                 | 1                                                                                                                                                |
| exit_timeout                     | 30                                                                                                                                               |
+----------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------+

I0630 09:01:04.653081 1 grpc_server.cc:4819] Started GRPCInferenceService at 0.0.0.0:8001
I0630 09:01:04.654435 1 http_server.cc:3477] Started HTTPService at 0.0.0.0:8000
I0630 09:01:04.696305 1 http_server.cc:184] Started Metrics Service at 0.0.0.0:8002
```

## Before you begin, You will need

* An AWS account - Copy `terraform.tfvars.example` to `terraform.tfvars` with details from your own account, such as VPC and Subnet IDs.
* [Packer](https://www.packer.io/) is used to create an Amazon Machine Image (AMI). An AMI is like a prepared EC2 instance that has not been started up yet.

* [Ansible](https://www.ansible.com/) is used within Packer to install some neccessary services while Packer is building the image.

* [Terraform](https://www.terraform.io/) is used to create the minimum AWS infrastructure we need. It will use the Image created by Packer.


## Build the AMI using Packer

### Initialize Packer

```
cd packer
packer init .
```

### Validate an image file

```
packer validate -var-file=triton.pkrvars.hcl triton.pkr.hcl
```

### Build the image

```
packer build -var-file=triton.pkrvars.hcl triton.pkr.hcl
```

### Debugging a build

Packer will stop if there is an error and ask you if you want to clean up or abort, useful for debugging

```
packer build -on-error=ask -var-file=triton.pkrvars.hcl triton.pkr.hcl
```


## Use Terraform to launch the AMI as part of an Auto scaling group.

Initialize Terraform

```
cd ..
terraform init
```

Show a plan of resources to be created

```
terrarform plan
```

Create resources

```
terraform apply
```

## Estimated cost

Assuming 3 x G5.xlarge Nvidia Triton inference servers

```
 Name                                                     Monthly Qty  Unit     Monthly Cost

 aws_autoscaling_group.triton_servers
 └─ aws_launch_template.triton_servers
    ├─ Instance usage (Linux/UNIX, on-demand, g5.xlarge)        2,190  hours       $2,459.37
    ├─ EC2 detailed monitoring                                     21  metrics         $6.30
    └─ block_device_mapping[0]
       └─ Storage (general purpose SSD, gp3)                    1,500  GB            $132.00

 OVERALL TOTAL                                                                    $2,597.67

*Usage costs can be estimated by updating Infracost Cloud settings, see docs for other options.

──────────────────────────────────
10 cloud resources were detected:
∙ 1 was estimated
∙ 9 were free

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━┳━━━━━━━━━━━━┓
┃ Project                                            ┃ Baseline cost ┃ Usage cost* ┃ Total cost ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━╋━━━━━━━━━━━━┫
┃ main                                               ┃ $2,598        ┃ $0.00       ┃ $2,598     ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━┻━━━━━━━━━━━━┛
```

## TFsec

4 issues related to allowing the security group entries open to `0.0.0.0`, for testing.