provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAZZ5YCGFPWULUHPM3"
  secret_key = "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"
}

resource "aws_ecr_repository" "repo2" {
  name = "xyramsoftkarthik2"
}

resource "aws_ecr_repository_policy" "xyramsoftkarthikpolicy2" {
  repository = aws_ecr_repository.repo2.name

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "new policy",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
          "arn:aws:iam::674159014239:role/PullECRxyramsoft123"
        ]
            },
            "Action": [
                "ecr:DescribeRepositories",
                "ecr:ListImages"
                
            ]
        }
    ]
}
EOF
}
