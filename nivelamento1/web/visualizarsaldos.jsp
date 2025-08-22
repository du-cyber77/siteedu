<%@page import="uteis.FormatUtils"%>
<%@page import="model.Pessoa"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Collections"%>
<%@page import="java.util.Comparator"%>
<%@page import="control.PessoaDAO, control.MovimentacaoDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="static/header.jsp" %>

<%
    PessoaDAO pessoaDAO = new PessoaDAO();
    MovimentacaoDAO movDAO = new MovimentacaoDAO();
    
    // Obter todas as pessoas
    List<Pessoa> pessoas = pessoaDAO.listaPessoas();
    
    // Parâmetros de filtro e ordenação
    String filtroNome = request.getParameter("filtroNome");
    String ordenarPor = request.getParameter("ordenarPor");
    String ordem = request.getParameter("ordem");
    
    // Aplicar filtro por nome se fornecido
    if (filtroNome != null && !filtroNome.trim().isEmpty()) {
        List<Pessoa> pessoasFiltradas = new ArrayList<>();
        for (Pessoa p : pessoas) {
            if (p.getNome().toUpperCase().contains(filtroNome.toUpperCase())) {
                pessoasFiltradas.add(p);
            }
        }
        pessoas = pessoasFiltradas;
    }
    
    // Calcular saldos para cada pessoa
    final java.util.Map<Integer, Double> mapaSaldos = new java.util.HashMap<>();
    for (Pessoa p : pessoas) {
        mapaSaldos.put(p.getId(), movDAO.calcularSaldoPorPessoa(p.getId()));
    }
    
    // Aplicar ordenação se fornecida
    if (ordenarPor != null) {
        final boolean ascendente = ordem == null || "asc".equals(ordem);
        
        if ("nome".equals(ordenarPor)) {
            Collections.sort(pessoas, new Comparator<Pessoa>() {
                public int compare(Pessoa p1, Pessoa p2) {
                    return ascendente ? 
                        p1.getNome().compareToIgnoreCase(p2.getNome()) : 
                        p2.getNome().compareToIgnoreCase(p1.getNome());
                }
            });
        } else if ("saldo".equals(ordenarPor)) {
            Collections.sort(pessoas, new Comparator<Pessoa>() {
                public int compare(Pessoa p1, Pessoa p2) {
                    Double saldo1 = mapaSaldos.get(p1.getId());
                    Double saldo2 = mapaSaldos.get(p2.getId());
                    return ascendente ? 
                        saldo1.compareTo(saldo2) : 
                        saldo2.compareTo(saldo1);
                }
            });
        }
    }
%>

<div class="container">
    <h1 class="text-center mt-4 mb-4">Sistema de Controle Financeiro - Visualização de Saldos</h1>
    
    <!-- Filtros e Ordenação -->
    <div class="card mb-4">
        <div class="card-header bg-primary text-white">
            <h4 class="mb-0">Filtros e Ordenação</h4>
        </div>
        <div class="card-body">
            <form method="get" action="visualizarsaldos.jsp" class="row g-3">
                <div class="col-md-4">
                    <label for="filtroNome" class="form-label">Filtrar por Nome:</label>
                    <input type="text" class="form-control" id="filtroNome" name="filtroNome" 
                           value="<%= filtroNome != null ? filtroNome : "" %>">
                </div>
                <div class="col-md-3">
                    <label for="ordenarPor" class="form-label">Ordenar por:</label>
                    <select class="form-select" id="ordenarPor" name="ordenarPor">
                        <option value="">Selecione...</option>
                        <option value="nome" <%= "nome".equals(ordenarPor) ? "selected" : "" %>>Nome</option>
                        <option value="saldo" <%= "saldo".equals(ordenarPor) ? "selected" : "" %>>Saldo</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label for="ordem" class="form-label">Ordem:</label>
                    <select class="form-select" id="ordem" name="ordem">
                        <option value="asc" <%= ordem == null || "asc".equals(ordem) ? "selected" : "" %>>Crescente</option>
                        <option value="desc" <%= "desc".equals(ordem) ? "selected" : "" %>>Decrescente</option>
                    </select>
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary w-100">Aplicar</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Tabela de Saldos -->
    <div class="card">
        <div class="card-header bg-success text-white">
            <h4 class="mb-0">Saldos</h4>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-striped table-hover">
                    <thead class="table-dark">
                        <tr>
                            <th>ID</th>
                            <th>Nome</th>
                            <th>CPF</th>
                            <th class="text-end">Saldo Atual</th>
                            <th>Detalhes</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                        double saldoTotal = 0.0;
                        for (Pessoa pessoa : pessoas) { 
                            double saldo = mapaSaldos.get(pessoa.getId());
                            saldoTotal += saldo;
                        %>
                            <tr>
                                <td><%= pessoa.getId() %></td>
                                <td><%= pessoa.getNome() %></td>
                                <td><%= pessoa.getCpf() %></td>
                                <td class="text-end <%= saldo < 0 ? "text-danger fw-bold" : "text-success" %>">
                                    <%= FormatUtils.formatarMoedaBR(saldo) %>
                                </td>
                                <td>
                                    <a href="detalhestransacoes.jsp?id=<%= pessoa.getId() %>" class="btn btn-info btn-sm">
                                        <i class="glyphicon glyphicon-info-sign"></i> Ver Detalhes
                                    </a>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                    <tfoot>
                        <tr class="table-dark">
                            <td colspan="3" class="text-end fw-bold">Saldo Total:</td>
                            <td class="text-end fw-bold <%= saldoTotal < 0 ? "text-danger" : "text-success" %>">
                                <%= FormatUtils.formatarMoedaBR(saldoTotal) %>
                            </td>
                            <td></td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        </div>
    </div>
    
    <div class="d-flex justify-content-between mt-4">
        <div class="pull-left">
                <a href="index.jsp" class="btn btn-default">
                    <i class="glyphicon glyphicon-home"></i> Voltar para a página inicial
                </a>
            </div>
        <a href="limpartodamovimentacao.jsp" class="btn btn-danger" 
           onclick="return confirm('Tem certeza que deseja limpar TODAS as movimentações? Esta ação não pode ser desfeita.');">
            <i class="glyphicon glyphicon-trash"></i> Limpar Todas Movimentações
        </a>
    </div>
</div>

<script>
    // Adicionar classes Bootstrap aos elementos existentes
    $(document).ready(function() {
        // Adicionar tooltip aos botões
        $('[data-toggle="tooltip"]').tooltip();
    });
</script>
