# Example: create-host
`create.rb` is a script which will generate a user data script for a new host launched in AWS. The generated script will grab a host factory token from S3, register an identity and conjurize itself using Conjur SSH management. The user data script will be printed to `STDOUT`.
## Usage
```
create.rb [options]
```
| Flags             | Description                                             |              |
|-------------------|---------------------------------------------------------|--------------|
| `-i` `--host-id`  | Identity of the host to be created                      | **required** |
| `-r` `--role`     | Name of the AWS IAM role with access to the token in S3 | **required** |
| `-b` `--bucket`   | Name of the bucket the token is stored in within S3     | **required** |
| `-c` `--cert`     | Path to the appliance certificate                       |              |
| `-h` `--help`     | Displays the help menu                                  |              |