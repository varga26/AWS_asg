resource "grafana_rule_group" "ec2_alerts" {
  name             = "EC2 Alerts"
  folder_uid       = grafana_folder.llm_monitoring.uid
  interval_seconds = 60
  org_id           = 1

  rule {
    name           = "[llm]-[test]-[ec2]-[high]-[cpu]"
    condition      = "B"
    for            = "5m"
    exec_err_state = "Alerting"
    no_data_state  = "NoData"

    data {
      ref_id = "A"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = grafana_data_source.prometheus.uid
      model = jsonencode({
        expr = "100 - (avg by (instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)"
        refId = "A"
      })
    }
    data {
      ref_id = "B"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = "-100"
      model = jsonencode({
        conditions = [
          {
            evaluator = { params = [80], type = "gt" }
            operator = { type = "and" }
            query = { params = ["A"] }
            reducer = { params = [], type = "last" }
            type = "query"
          }
        ]
        datasource = { type = "__expr__", uid = "-100" }
        refId = "B"
        type = "classic_conditions"
      })
    }
  }

  rule {
    name           = "[llm]-[test]-[ec2]-[low]-[cpu]"
    condition      = "B"
    for            = "5m"
    exec_err_state = "Alerting"
    no_data_state  = "NoData"

    data {
      ref_id = "A"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = grafana_data_source.prometheus.uid
      model = jsonencode({
        expr = "100 - (avg by (instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)"
        refId = "A"
      })
    }
    data {
      ref_id = "B"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = "-100"
      model = jsonencode({
        conditions = [
          {
            evaluator = { params = [10], type = "lt" }
            operator = { type = "and" }
            query = { params = ["A"] }
            reducer = { params = [], type = "last" }
            type = "query"
          }
        ]
        datasource = { type = "__expr__", uid = "-100" }
        refId = "B"
        type = "classic_conditions"
      })
    }
  }
}

resource "grafana_rule_group" "rds_alerts" {
  name             = "RDS Alerts"
  folder_uid       = grafana_folder.llm_monitoring.uid
  interval_seconds = 60
  org_id           = 1

  rule {
    name           = "[llm]-[test]-[db]-[high]-[cpu]"
    condition      = "B"
    for            = "5m"
    exec_err_state = "Alerting"
    no_data_state  = "NoData"

    data {
      ref_id = "A"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = grafana_data_source.cloudwatch.uid
      model = jsonencode({
        region     = "default"
        namespace  = "AWS/RDS"
        metricName = "CPUUtilization"
        dimensions = {
          DBInstanceIdentifier = module.db.rds_identifier
        }
        statistic        = "Average"
        period           = "300"
        matchExact       = false
        metricQueryType  = 0
        metricEditorMode = 0
        refId            = "A"
      })
    }
    data {
      ref_id = "B"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = "-100"
      model = jsonencode({
        conditions = [
          {
            evaluator = { params = [80], type = "gt" }
            operator = { type = "and" }
            query = { params = ["A"] }
            reducer = { params = [], type = "last" }
            type = "query"
          }
        ]
        datasource = { type = "__expr__", uid = "-100" }
        refId = "B"
        type = "classic_conditions"
      })
    }
  }

  rule {
    name           = "[llm]-[test]-[db]-[low]-[storage]"
    condition      = "B"
    for            = "5m"
    exec_err_state = "Alerting"
    no_data_state  = "NoData"

    data {
      ref_id = "A"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = grafana_data_source.cloudwatch.uid
      model = jsonencode({
        region     = "default"
        namespace  = "AWS/RDS"
        metricName = "FreeStorageSpace"
        dimensions = {
          DBInstanceIdentifier = module.db.rds_identifier
        }
        statistic        = "Average"
        period           = "300"
        matchExact       = false
        metricQueryType  = 0
        metricEditorMode = 0
        refId            = "A"
      })
    }
    data {
      ref_id = "B"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = "-100"
      model = jsonencode({
        conditions = [
          {
            evaluator = { params = [5000000000], type = "lt" } # 5 GB
            operator = { type = "and" }
            query = { params = ["A"] }
            reducer = { params = [], type = "last" }
            type = "query"
          }
        ]
        datasource = { type = "__expr__", uid = "-100" }
        refId = "B"
        type = "classic_conditions"
      })
    }
  }
}

resource "grafana_rule_group" "elb_alerts" {
  name             = "ELB Alerts"
  folder_uid       = grafana_folder.llm_monitoring.uid
  interval_seconds = 60
  org_id           = 1

  rule {
    name           = "[llm]-[test]-[elb]-[medium]-[5XX-errors]"
    condition      = "B"
    for            = "5m"
    exec_err_state = "Alerting"
    no_data_state  = "NoData"

    data {
      ref_id = "A"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = grafana_data_source.cloudwatch.uid
      model = jsonencode({
        region     = "default"
        namespace  = "AWS/ApplicationELB"
        metricName = "HTTPCode_Target_5XX_Count"
        dimensions = {
          LoadBalancer = module.lb.alb_arn_suffix
        }
        statistic        = "Sum"
        period           = "300"
        matchExact       = false
        metricQueryType  = 0
        metricEditorMode = 0
        refId            = "A"
      })
    }
    data {
      ref_id = "B"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = "-100"
      model = jsonencode({
        conditions = [
          {
            evaluator = { params = [10], type = "gt" }
            operator = { type = "and" }
            query = { params = ["A"] }
            reducer = { params = [], type = "last" }
            type = "query"
          }
        ]
        datasource = { type = "__expr__", uid = "-100" }
        refId = "B"
        type = "classic_conditions"
      })
    }
  }

  rule {
    name           = "[llm]-[test]-[openwebui]-[low]-[healthy-hosts]"
    condition      = "B"
    for            = "5m"
    exec_err_state = "Alerting"
    no_data_state  = "NoData"

    data {
      ref_id = "A"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = grafana_data_source.cloudwatch.uid
      model = jsonencode({
        region     = "default"
        namespace  = "AWS/ApplicationELB"
        metricName = "HealthyHostCount"
        dimensions = {
          LoadBalancer = module.lb.alb_arn_suffix
          TargetGroup  = module.lb.target_group_arn_suffix
        }
        statistic        = "Average"
        period           = "300"
        matchExact       = false
        metricQueryType  = 0
        metricEditorMode = 0
        refId            = "A"
      })
    }
    data {
      ref_id = "B"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = "-100"
      model = jsonencode({
        conditions = [
          {
            evaluator = { params = [2], type = "lt" }
            operator = { type = "and" }
            query = { params = ["A"] }
            reducer = { params = [], type = "last" }
            type = "query"
          }
        ]
        datasource = { type = "__expr__", uid = "-100" }
        refId = "B"
        type = "classic_conditions"
      })
    }
  }

  rule {
    name           = "[llm]-[test]-[ollama]-[low]-[healthy-hosts]"
    condition      = "B"
    for            = "5m"
    exec_err_state = "Alerting"
    no_data_state  = "NoData"

    data {
      ref_id = "A"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = grafana_data_source.cloudwatch.uid
      model = jsonencode({
        region     = "default"
        namespace  = "AWS/NetworkELB"
        metricName = "HealthyHostCount"
        dimensions = {
          LoadBalancer = module.lb.ollama_lb_arn_suffix
          TargetGroup  = module.lb.ollama_target_group_arn_suffix
        }
        statistic        = "Average"
        period           = "300"
        matchExact       = false
        metricQueryType  = 0
        metricEditorMode = 0
        refId            = "A"
      })
    }
    data {
      ref_id = "B"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = "-100"
      model = jsonencode({
        conditions = [
          {
            evaluator = { params = [1], type = "lt" }
            operator = { type = "and" }
            query = { params = ["A"] }
            reducer = { params = [], type = "last" }
            type = "query"
          }
        ]
        datasource = { type = "__expr__", uid = "-100" }
        refId = "B"
        type = "classic_conditions"
      })
    }
  }
}
