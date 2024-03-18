# clef-2024-infra

Terraform modules for handling most of the VM and bucket setup for the competition.

## notes

### generating a service account key

We generate a key for the label-studio service account and upload it to the secrets manager:

```bash
# create the key
gcloud iam service-accounts keys create secrets/label_studio_key.json --iam-account label-studio@dsgt-clef-2024.iam.gserviceaccount.com

# sops it
sops -e secrets/label_studio_key.json > secrets/label_studio_key.sops.json
```
