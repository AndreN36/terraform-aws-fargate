run "validar_nome" {
    command = apply

    assert {
        condition     = aws_ecs_task_definition.main.container_definitions[0].name == var.app_name
        error_message = "O nome não é valido"
    }
}