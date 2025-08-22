<%-- 
    Document   : historico_geral
    Created on : 21 de mai. de 2025, 16:39:51
    Author     : Eduardo Almeida
--%>
<%@page import="uteis.FormatUtils"%>
<%@page import="model.Movimentacao, model.Pessoa"%>
<%@page import="java.util.ArrayList, java.util.List, java.text.SimpleDateFormat"%>
<%@page import="java.util.Collections, java.util.Comparator, java.util.HashMap, java.util.Map"%>
<%@page import="control.MovimentacaoDAO, control.PessoaDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="static/header.jsp" %>

<%
    MovimentacaoDAO movDAO = new MovimentacaoDAO();
    PessoaDAO pessoaDAO = new PessoaDAO();
    
    // Obter todas as movimentações
    List<Movimentacao> movimentacoes = movDAO.listarMovimentacoes();
    
    // Parâmetros de filtro e ordenação
    String filtroTipo = request.getParameter("filtroTipo");
    String filtroPeriodo = request.getParameter("filtroPeriodo");
    String ordenarPor = request.getParameter("ordenarPor");
    String ordem = request.getParameter("ordem");
    
    // Criar mapa de IDs de pessoas para nomes
    Map<Integer, String> mapaNomes = new HashMap<>();
    List<Pessoa> pessoas = pessoaDAO.listaPessoas();
    for (Pessoa p : pessoas) {
        mapaNomes.put(p.getId(), p.getNome());
    }
    
    // Aplicar filtro por tipo se fornecido
    if (filtroTipo != null && !filtroTipo.trim().isEmpty() && !"todos".equals(filtroTipo)) {
        List<Movimentacao> movFiltradas = new ArrayList<>();
        for (Movimentacao m : movimentacoes) {
            if ("credito".equals(filtroTipo) && m.getCredito() > 0) {
                movFiltradas.add(m);
            } else if ("debito".equals(filtroTipo) && m.getDebito() > 0) {
                movFiltradas.add(m);
            }
        }
        movimentacoes = movFiltradas;
    }
    
    // Aplicar filtro por período se fornecido
    if (filtroPeriodo != null && !filtroPeriodo.trim().isEmpty() && !"todos".equals(filtroPeriodo)) {
        List<Movimentacao> movFiltradas = new ArrayList<>();
        long agora = System.currentTimeMillis();
        long umDia = 24 * 60 * 60 * 1000;
        
        for (Movimentacao m : movimentacoes) {
            long dataOp = m.getDataOperacao().getTime();
            
            if ("hoje".equals(filtroPeriodo) && (agora - dataOp < umDia)) {
                movFiltradas.add(m);
            } else if ("semana".equals(filtroPeriodo) && (agora - dataOp < 7 * umDia)) {
                movFiltradas.add(m);
            } else if ("mes".equals(filtroPeriodo) && (agora - dataOp < 30 * umDia)) {
                movFiltradas.add(m);
            }
        }
        movimentacoes = movFiltradas;
    }
    
    // Aplicar ordenação se fornecida
    if (ordenarPor != null) {
        final boolean ascendente = ordem == null || "asc".equals(ordem);
        
        if ("data".equals(ordenarPor)) {
            Collections.sort(movimentacoes, new Comparator<Movimentacao>() {
                public int compare(Movimentacao m1, Movimentacao m2) {
                    return ascendente ? 
                        m1.getDataOperacao().compareTo(m2.getDataOperacao()) : 
                        m2.getDataOperacao().compareTo(m1.getDataOperacao());
                }
            });
        } else if ("valor".equals(ordenarPor)) {
            Collections.sort(movimentacoes, new Comparator<Movimentacao>() {
                public int compare(Movimentacao m1, Movimentacao m2) {
                    double valor1 = m1.getCredito() - m1.getDebito();
                    double valor2 = m2.getCredito() - m2.getDebito();
                    return ascendente ? 
                        Double.compare(valor1, valor2) : 
                        Double.compare(valor2, valor1);
                }
            });
        } else if ("pessoa".equals(ordenarPor)) {
            Collections.sort(movimentacoes, new Comparator<Movimentacao>() {
                public int compare(Movimentacao m1, Movimentacao m2) {
                    String nome1 = mapaNomes.getOrDefault(m1.getIdPessoa(), "");
                    String nome2 = mapaNomes.getOrDefault(m2.getIdPessoa(), "");
                    return ascendente ? 
                        nome1.compareToIgnoreCase(nome2) : 
                        nome2.compareToIgnoreCase(nome1);
                }
            });
        }
    } else {
        // Ordenação padrão: data mais recente primeiro
        Collections.sort(movimentacoes, new Comparator<Movimentacao>() {
            public int compare(Movimentacao m1, Movimentacao m2) {
                return m2.getDataOperacao().compareTo(m1.getDataOperacao());
            }
        });
    }
    
    // Formatar datas com horário completo
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
%>

<div class="container">
    <h1 class="text-center mt-4 mb-4">Histórico Geral de Movimentações</h1>
    
    <!-- Filtros e Ordenação -->
    <div class="card mb-4">
        <div class="card-header bg-primary text-white">
            <h4 class="mb-0">Filtros e Ordenação</h4>
        </div>
        <div class="card-body">
            <form method="get" action="historico_geral.jsp" class="row g-3">
                <div class="col-md-3">
                    <label for="filtroTipo" class="form-label">Tipo de Operação:</label>
                    <select class="form-select" id="filtroTipo" name="filtroTipo">
                        <option value="todos" <%= filtroTipo == null || "todos".equals(filtroTipo) ? "selected" : "" %>>Todos</option>
                        <option value="credito" <%= "credito".equals(filtroTipo) ? "selected" : "" %>>Créditos</option>
                        <option value="debito" <%= "debito".equals(filtroTipo) ? "selected" : "" %>>Débitos</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label for="filtroPeriodo" class="form-label">Período:</label>
                    <select class="form-select" id="filtroPeriodo" name="filtroPeriodo">
                        <option value="todos" <%= filtroPeriodo == null || "todos".equals(filtroPeriodo) ? "selected" : "" %>>Todos</option>
                        <option value="hoje" <%= "hoje".equals(filtroPeriodo) ? "selected" : "" %>>Hoje</option>
                        <option value="semana" <%= "semana".equals(filtroPeriodo) ? "selected" : "" %>>Última semana</option>
                        <option value="mes" <%= "mes".equals(filtroPeriodo) ? "selected" : "" %>>Último mês</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label for="ordenarPor" class="form-label">Ordenar por:</label>
                    <select class="form-select" id="ordenarPor" name="ordenarPor">
                        <option value="data" <%= ordenarPor == null || "data".equals(ordenarPor) ? "selected" : "" %>>Data</option>
                        <option value="valor" <%= "valor".equals(ordenarPor) ? "selected" : "" %>>Valor</option>
                        <option value="pessoa" <%= "pessoa".equals(ordenarPor) ? "selected" : "" %>>Pessoa</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label for="ordem" class="form-label">Ordem:</label>
                    <select class="form-select" id="ordem" name="ordem">
                        <option value="desc" <%= ordem == null || "desc".equals(ordem) ? "selected" : "" %>>Decrescente</option>
                        <option value="asc" <%= "asc".equals(ordem) ? "selected" : "" %>>Crescente</option>
                    </select>
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary w-100">Aplicar</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Tabela de Movimentações -->
    <div class="card">
        <div class="card-header bg-info text-white">
            <h4 class="mb-0">Movimentações</h4>
        </div>
        <div class="card-body">
            <% if (movimentacoes.isEmpty()) { %>
                <div class="alert alert-info">
                    <i class="glyphicon glyphicon-info-sign"></i> Nenhuma movimentação encontrada com os filtros selecionados.
                </div>
            <% } else { %>
                <div class="table-responsive">
                    <table class="table table-striped table-hover">
                        <thead class="table-dark">
                            <tr>
                                <th>ID</th>
                                <th>Data/Hora</th>
                                <th>Pessoa</th>
                                <th>Descrição</th>
                                <th class="text-end">Crédito</th>
                                <th class="text-end">Débito</th>
                                <th class="text-end">Valor Líquido</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                            double totalCreditos = 0.0;
                            double totalDebitos = 0.0;
                            
                            for (Movimentacao mov : movimentacoes) { 
                                double valorLiquido = mov.getCredito() - mov.getDebito();
                                totalCreditos += mov.getCredito();
                                totalDebitos += mov.getDebito();
                                String nomePessoa = mapaNomes.getOrDefault(mov.getIdPessoa(), "Desconhecido");
                            %>
                                <tr>
                                    <td><%= mov.getId() %></td>
                                    <td><%= sdf.format(mov.getDataOperacao()) %></td>
                                    <td><%= nomePessoa %></td>
                                    <td><%= mov.getObs() %></td>
                                    <td class="text-end text-success">
                                    <%= mov.getCredito() > 0 ? FormatUtils.formatarMoedaBR(mov.getCredito()) : "-" %>
                                    </td>
                                    <td class="text-end text-danger">
                                    <%= mov.getDebito() > 0 ? FormatUtils.formatarMoedaBR(mov.getDebito()) : "-" %>
                                    </td>
                                    <td class="text-end <%= valorLiquido < 0 ? "text-danger fw-bold" : "text-success" %>">
                                    <%= FormatUtils.formatarMoedaBR(valorLiquido) %>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                        <tfoot>
                            <tr class="table-dark">
                                <td colspan="4" class="text-end fw-bold">Totais:</td>
                                <td class="text-end text-success fw-bold"><%= FormatUtils.formatarMoedaBR(totalCreditos) %></td>
                                <td class="text-end text-danger fw-bold"><%= FormatUtils.formatarMoedaBR(totalDebitos) %></td>
                                <td class="text-end <%= (totalCreditos - totalDebitos) < 0 ? "text-danger" : "text-success" %> fw-bold">
                                <%= FormatUtils.formatarMoedaBR(totalCreditos - totalDebitos) %>
                                </td>
                            </tr>
                        </tfoot>
                    </table>
                </div>
            <% } %>
        </div>
    </div>
    
    <div class="d-flex justify-content-between mt-4 mb-5">
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
