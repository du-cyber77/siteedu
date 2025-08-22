<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="pt-BR">
    <head>
        
        <meta charset="UTF-8">
        <title>Sistema Financeiro</title>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet"/>
        <!-- Adicionando o JavaScript do Bootstrap para os dropdowns funcionarem -->
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
        <link href="bootstrap-navbar-mobile.css" rel="stylesheet" type="text/css"/>
        <script src="bootstrap-navbar-mobile.js" type="text/javascript"></script>
        <!-- Adicionar no header.jsp após os outros CSS -->
        <link href="static/responsive.css" rel="stylesheet" type="text/css"/>
        <!-- CSS Moderno Integrado -->
        <link href="static/modern-style.css" rel="stylesheet" type="text/css"/>
        <!-- CSS de Animações -->
        <link href="static/animations.css" rel="stylesheet" type="text/css"/>
        <!-- Fonte Roboto do Google Fonts -->
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">

        

        <style>
            /* Estilos básicos mantidos para compatibilidade */
            footer {
                position: absolute;
                bottom: 0;
                width: 100%;
                color: #fff;
                background-color: #000;
            }

            a:link, a:visited, a:hover, a:active {
                text-decoration: none;
            }
            
            /* Ajuste para o dropdown no navbar */
            .navbar-nav > li > .dropdown-menu {
                margin-top: 0;
                border-top-left-radius: 0;
                border-top-right-radius: 0;
            }
        </style>
    </head>
    <body>
        <header>
            <nav class="navbar navbar-default navbar-fixed-top">
                <div class="container">
                    <ul class="nav navbar-nav navbar-default navbar-mobile">
                        <!-- Link Home Direto -->
                        <li><a href="<%= request.getContextPath() %>/">Home</a></li>

                        <!-- Menu Dropdown Pessoas -->
                        <li class="dropdown">
                            <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                                Pessoas <span class="caret"></span>
                            </a>
                            <ul class="dropdown-menu">
                                <li><a href="form_cadastrarpessoa.jsp">Cadastrar Pessoa</a></li>
                                <li><a href="listartodaspessoas.jsp">Listagem de Pessoas</a></li>
                            </ul>
                        </li>

                        <!-- Menu Dropdown Pesquisar -->
                        <li class="dropdown">
                            <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                                Pesquisar <span class="caret"></span>
                            </a>
                            <ul class="dropdown-menu">
                                <li><a href="pesquisarpessoa.jsp">Pesquisar Pessoa</a></li>
                                <li><a href="pesquisarpessoaavancado.jsp">Pesquisar Pessoa Avançado</a></li>
                            </ul>
                        </li>

                        <!-- Menu Dropdown Relatórios -->
                        <li class="dropdown">
                            <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                                Relatórios <span class="caret"></span>
                            </a>
                            <ul class="dropdown-menu">
                                <li><a href="visualizartransacoes.jsp">Visualizar Transações</a></li>
                                <li><a href="visualizarsaldos.jsp">Visualizar Saldos</a></li>
                                <li><a href="historico_geral.jsp">Histórico Geral</a></li>
                            </ul>
                        </li>
                        
                        <!-- Adicionei um separador visual, opcional -->
                        <!-- <li class="divider-vertical"></li> -->

                        <!-- Outros itens de menu podem ser adicionados aqui se necessário -->
                    </ul>
                </div>
            </nav>
        </header>
        <br><br><br><br>


