# dataproc serverless

- https://cloud.google.com/blog/products/data-analytics/tune-spark-properties-to-optimize-dataproc-serverless-jobs
- https://cloud.google.com/dataproc-serverless/pricing
- https://cloud.google.com/dataproc/docs/concepts/jobs/history-server

```bash
gcloud dataproc clusters create spark-job-history --enable-component-gateway --bucket dsgt-clef-2024-dataproc --region us-central1 --single-node --master-machine-type e2-standard-4 --master-boot-disk-type pd-balanced --master-boot-disk-size 30 --image-version 2.1-debian11 --project dsgt-clef-2024
```
