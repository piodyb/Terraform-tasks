variable "buckets" {
  type = list(any)
  default = [
    {
      name       = "bucket1testgogogo123"
      encryption = false
    },
    {
      name       = "bucket2testgogogo123"
      encryption = false
    },
    {
      name       = "bucket3testgogogo123"
      encryption = true
    }
  ]
}
