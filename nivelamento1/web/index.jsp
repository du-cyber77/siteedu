<%@page import="uteis.FormatUtils"%>
<%@page import="model.Movimentacao, model.Pessoa"%>
<%@page import="java.util.ArrayList, java.util.List"%>
<%@page import="control.MovimentacaoDAO, control.PessoaDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="static/header.jsp" %>

<%
    // Obter dados para o dashboard
    PessoaDAO pessoaDAO = new PessoaDAO();
    MovimentacaoDAO movDAO = new MovimentacaoDAO();
    
    // Total de pessoas cadastradas
    List<Pessoa> pessoas = pessoaDAO.listaPessoas();
    int totalPessoas = pessoas.size();
    
    // Total de movimentações - Tratamento de erro
    List<Movimentacao> movimentacoes = new ArrayList<>();
    try {
        movimentacoes = movDAO.listarMovimentacoes();
    } catch (Exception e) {
        // Em caso de erro, apenas continua com lista vazia
       
    }
    int totalMovimentacoes = movimentacoes.size();
    
    // Calcular saldos
    double saldoTotal = 0.0;
    double totalCreditos = 0.0;
    double totalDebitos = 0.0;
    
    for (Movimentacao mov : movimentacoes) {
        totalCreditos += mov.getCredito();
        totalDebitos += mov.getDebito();
    }
    saldoTotal = totalCreditos - totalDebitos;
    
    // Contar pessoas com saldo positivo e negativo
    int pessoasSaldoPositivo = 0;
    int pessoasSaldoNegativo = 0;
    
    for (Pessoa p : pessoas) {
        double saldo = movDAO.calcularSaldoPorPessoa(p.getId());
        if (saldo > 0) {
            pessoasSaldoPositivo++;
        } else if (saldo < 0) {
            pessoasSaldoNegativo++;
        }
    }
    
    // Obter movimentações recentes (últimas 5)
    List<Movimentacao> movimentacoesRecentes = new ArrayList<>();
    if (movimentacoes.size() > 0) {
        // Ordenar por data (mais recente primeiro)
        java.util.Collections.sort(movimentacoes, new java.util.Comparator<Movimentacao>() {
            public int compare(Movimentacao m1, Movimentacao m2) {
                return m2.getDataOperacao().compareTo(m1.getDataOperacao());
            }
        });
        
        // Pegar as 5 primeiras (ou menos se não houver 5)
        int limite = Math.min(5, movimentacoes.size());
        for (int i = 0; i < limite; i++) {
            movimentacoesRecentes.add(movimentacoes.get(i));
        }
    }
    
    // Criar mapa de IDs de pessoas para nomes
    java.util.Map<Integer, String> mapaNomes = new java.util.HashMap<>();
    for (Pessoa p : pessoas) {
        mapaNomes.put(p.getId(), p.getNome());
    }
    
    // Formatar datas
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
    
    // Calcular porcentagens para a barra de progresso
    double percentCredito = 0;
    double percentDebito = 0;
    
    if (totalCreditos + totalDebitos > 0) {
        percentCredito = (totalCreditos / (totalCreditos + totalDebitos)) * 100;
        percentDebito = (totalDebitos / (totalCreditos + totalDebitos)) * 100;
    }
%>

<div class="container">
    <div class="jumbotron bg-primary text-white text-center mt-4 mb-4">
        <h1>Sistema de Controle Financeiro</h1>
        <p class="lead">Resumo de Estatísticas Gerais</p>
    </div>
    
    <!-- Cards de Estatísticas -->
    <div class="row mb-4">
        <div class="col-md-3">
            <div class="card text-white bg-info h-100">
                <div class="card-body text-center">
                    <h1 class="display-4"><%= totalPessoas %></h1>
                    <h5 class="card-title">Pessoas Cadastradas</h5>
                </div>
                <div class="card-footer text-center">
                    <a href="listartodaspessoas.jsp" class="text-white">Ver Detalhes</a>
                </div>
            </div>
        </div>
        
        <div class="col-md-3">
            <div class="card text-white <%= saldoTotal >= 0 ? "bg-success" : "bg-danger" %> h-100">
                <div class="card-body text-center">
                    <h1 class="display-4"><%= FormatUtils.formatarMoedaBR(saldoTotal) %></h1>
                    <h5 class="card-title">Saldo Total</h5>
                </div>
                <div class="card-footer text-center">
                    <a href="visualizarsaldos.jsp" class="text-white">Ver Detalhes</a>
                </div>
            </div>
        </div>
        
        <div class="col-md-3">
            <div class="card text-white bg-warning h-100">
                <div class="card-body text-center">
                    <h1 class="display-4"><%= totalMovimentacoes %></h1>
                    <h5 class="card-title">Movimentações</h5>
                </div>
                <div class="card-footer text-center">
                    <a href="historico_geral.jsp" class="text-white">Ver Detalhes</a>
                </div>
            </div>
        </div>
        
        <div class="col-md-3">
            <div class="card text-white bg-secondary h-100">
                <div class="card-body text-center">
                    <h1 class="display-4"><%= pessoasSaldoPositivo %> / <%= pessoasSaldoNegativo %></h1>
                    <h5 class="card-title">Saldos Positivos/Negativos</h5>
                </div>
                <div class="card-footer text-center">
                    <a href="visualizarsaldos.jsp" class="text-white">Ver Detalhes</a>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Gráficos de Resumo -->
    <div class="row mb-4">
        <div class="col-md-6">
            <div class="card">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0">Resumo Financeiro</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <tr>
                                <th>Total de Créditos:</th>
                                <td class="text-success text-end"><%= FormatUtils.formatarMoedaBR(totalCreditos) %></td>
                            </tr>
                            <tr>
                                <th>Total de Débitos:</th>
                                <td class="text-danger text-end"><%= FormatUtils.formatarMoedaBR(totalDebitos) %></td>
                            </tr>
                            <tr class="table-active">
                                <th>Saldo Total:</th>
                                <td class="<%= saldoTotal >= 0 ? "text-success" : "text-danger" %> text-end fw-bold">
                                    <%= FormatUtils.formatarMoedaBR(saldoTotal) %>
                                </td>
                            </tr>
                        </table>
                    </div>
                    
                    <!-- Barra de progresso visual -->
                    <% if (totalCreditos + totalDebitos > 0) { %>
                        <div class="mt-4">
                            <h6 class="mb-2">Distribuição de Créditos e Débitos</h6>
                            <div class="progress" style="height: 30px; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 5px rgba(0,0,0,0.1);">
                                <div class="progress-bar bg-success" role="progressbar" 
                                     style="width: <%= percentCredito %>%; font-weight: bold;" 
                                     aria-valuenow="<%= percentCredito %>" aria-valuemin="0" aria-valuemax="100">
                                    <%= String.format("%.1f%%", percentCredito) %> (<%= FormatUtils.formatarMoedaBR(totalCreditos) %>)
                                </div>
                                
                                <div class="progress-bar bg-danger" role="progressbar" 
                                     style="width: <%= percentDebito %>%; font-weight: bold;" 
                                     aria-valuenow="<%= percentDebito %>" aria-valuemin="0" aria-valuemax="100">
                                    <%= String.format("%.1f%%", percentDebito) %> (<%= FormatUtils.formatarMoedaBR(totalDebitos) %>)
                                </div>
                            </div>
                            <div class="d-flex justify-content-between mt-2">
                                <small class="text-success">Créditos: <%= String.format("%.1f%%", percentCredito) %></small>
                                <small class="text-danger">Débitos: <%= String.format("%.1f%%", percentDebito) %></small>
                            </div>
                        </div>
                    <% } else { %>
                        <div class="alert alert-info mt-4">
                            <i class="glyphicon glyphicon-info-sign"></i> Nenhuma movimentação registrada ainda.
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
        
        <div class="col-md-6">
            <div class="card">
                <div class="card-header bg-info text-white">
                    <h5 class="mb-0">Últimas Movimentações</h5>
                </div>
                <div class="card-body">
                    <% if (movimentacoesRecentes.isEmpty()) { %>
                        <div class="alert alert-info">
                            <i class="glyphicon glyphicon-info-sign"></i> Nenhuma movimentação registrada ainda.
                        </div>
                    <% } else { %>
                        <div class="table-responsive">
                            <table class="table table-sm table-striped">
                                <thead>
                                    <tr>
                                        <th>Data</th>
                                        <th>Pessoa</th>
                                        <th>Descrição</th>
                                        <th class="text-end">Valor</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (Movimentacao mov : movimentacoesRecentes) { 
                                        double valor = mov.getCredito() - mov.getDebito();
                                        String nomePessoa = mapaNomes.getOrDefault(mov.getIdPessoa(), "Desconhecido");
                                    %>
                                        <tr>
                                            <td><%= sdf.format(mov.getDataOperacao()) %></td>
                                            <td><%= nomePessoa %></td>
                                            <td><%= mov.getObs() %></td>
                                            <td class="<%= valor >= 0 ? "text-success" : "text-danger" %> text-end">
                                                <%= FormatUtils.formatarMoedaBR(valor) %>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                        <div class="text-center mt-3">
                            <a href="historico_geral.jsp" class="btn btn-info">
                                <i class="glyphicon glyphicon-list"></i> Ver todas as movimentações
                            </a>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Botões de Ação Rápida -->
    <div class="row mb-5">
    <div class="col-12">
        <div class="card">
            <div class="card-header bg-success text-white">
                <h5>Ações Rápidas</h5>
            </div>
            <div class="card-body">
                <div class="d-flex justify-content-around flex-wrap">
                    <a href="form_cadastrarpessoa.jsp" class="btn btn-primary m-2">
                        <i class="glyphicon glyphicon-user"></i> Cadastrar Pessoa
                    </a>
                    <a href="visualizartransacoes.jsp" class="btn btn-success m-2">
                        <i class="glyphicon glyphicon-transfer"></i> Realizar Operação
                    </a>
                    <a href="visualizarsaldos.jsp" class="btn btn-info m-2">
                        <i class="glyphicon glyphicon-list-alt"></i> Visualizar Saldos
                    </a>
                    <a href="historico_geral.jsp" class="btn btn-warning m-2">
                        <i class="glyphicon glyphicon-time"></i> Histórico Geral
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
