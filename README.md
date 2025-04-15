# Oak Terraform Modules

## Modules

* [API](modules/gcp_api)
* [Firestore](modules/gcp_firestore)
* [SQL](modules/gcp_sql)

## Developing with modules

Developing a module is slightly trickier than just writing straight Terraform. Here are some tips to help you ease the process.

### Keeping it local

When writing a module you will need some code to call that module and test if it works. Far and away the easiest way to do this is create a subdirectory for your module, put all your module config in there, call it from the main Terraform config and finally copy all that config to this repo when it is working.

```hcl
module "example" {
  source = "./module"

  ...
}
```

### Double dots 

If the workspace is processed locally i.e. not in Terraform Cloud, you can have this repo checked out locally and link to it within the module using a relative or full path.

Note. This will not work if the workspace is processed in Terraform Cloud as TFC cannot resolve the path.

```hcl
module "example" {
  source = "../../oak-terraform-modules/modules/example"

  ...
}
```

### Pointing to a different branch

It is possible to work from this repo, although this is a slower process.

1. Point the module to your new branch
2. Push your changes to Github
3. Update Terraform `terraform init -upgrade`
4. Repeat from 2. until it works

Note. If the branch name has a `/` in it you need to replace that with the URL encoded equivalent: `%2F`

```hcl
module "example" {
  source = "github.com/oaknational/oak-terraform-modules//modules/example?ref=feat%2Fexample"

  ...
}
```
