<%@page import="model.Pessoa"%>
<%@page import="model.Movimentacao"%>
<%@page import="java.util.ArrayList, java.util.List, java.text.SimpleDateFormat"%>
<%@page import="java.util.Collections, java.util.Comparator, java.util.HashMap, java.util.Map"%>
<%@page import="control.MovimentacaoDAO, control.PessoaDAO"%>
<%@page import="uteis.FormatUtils"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="static/header.jsp" %>

<%
    PessoaDAO pessoaDAO = new PessoaDAO();
    MovimentacaoDAO movDAO = new MovimentacaoDAO();
    
    // Obter todas as pessoas
    List<Pessoa> pessoas = pessoaDAO.listaPessoas();
    
    // Parâmetros de filtro e ordenação
    String filtroNome = request.getParameter("filtroNome");
    String filtroTipoOperacao = request.getParameter("filtroTipoOperacao");
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
    
    // Mapa para armazenar as movimentações de cada pessoa
    Map<Integer, List<Movimentacao>> mapaMovimentacoes = new HashMap<>();
    
    // Mapa para armazenar os saldos de cada pessoa
    Map<Integer, Double> mapaSaldos = new HashMap<>();
    
    // Mapa para armazenar estatísticas de cada pessoa
    Map<Integer, Map<String, Object>> mapaEstatisticas = new HashMap<>();
    
    // Formatar datas
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    
    // Para cada pessoa, obter movimentações e calcular estatísticas
    for (Pessoa p : pessoas) {
        int idPessoa = p.getId();
        
        // Obter movimentações da pessoa
        List<Movimentacao> movsPessoa = movDAO.listarMovimentacoesPorPessoa(idPessoa);
        
        // Filtrar por tipo de operação se especificado
        if (filtroTipoOperacao != null && !filtroTipoOperacao.isEmpty() && !"todos".equals(filtroTipoOperacao)) {
            List<Movimentacao> movsFiltradas = new ArrayList<>();
            
            for (Movimentacao m : movsPessoa) {
                String obs = m.getObs().toLowerCase();
                
                if ("deposito".equals(filtroTipoOperacao) && 
                    (obs.contains("depósito") || obs.contains("deposito") || m.getCredito() > 0 && m.getDebito() == 0)) {
                    movsFiltradas.add(m);
                } 
                else if ("saque".equals(filtroTipoOperacao) && 
                         (obs.contains("saque") || m.getDebito() > 0 && m.getCredito() == 0 && !obs.contains("transferência"))) {
                    movsFiltradas.add(m);
                }
                else if ("transferencia".equals(filtroTipoOperacao) && 
                         (obs.contains("transferência") || obs.contains("transferencia"))) {
                    movsFiltradas.add(m);
                }
            }
            
            movsPessoa = movsFiltradas;
        }
        
        // Armazenar movimentações no mapa
        mapaMovimentacoes.put(idPessoa, movsPessoa);
        
        // Calcular saldo
        double saldo = movDAO.calcularSaldoPorPessoa(idPessoa);
        mapaSaldos.put(idPessoa, saldo);
        
        // Calcular estatísticas
        Map<String, Object> estatisticas = new HashMap<>();
        
        // Total de operações
        estatisticas.put("totalOperacoes", movsPessoa.size());
        
        // Última operação
        if (!movsPessoa.isEmpty()) {
            // Ordenar por data (mais recente primeiro)
            Collections.sort(movsPessoa, new Comparator<Movimentacao>() {
                public int compare(Movimentacao m1, Movimentacao m2) {
                    return m2.getDataOperacao().compareTo(m1.getDataOperacao());
                }
            });
            
            estatisticas.put("ultimaOperacao", movsPessoa.get(0));
        }
        
        // Contar tipos de operação
        int depositos = 0;
        int saques = 0;
        int transferencias = 0;
        double totalCreditos = 0;
        double totalDebitos = 0;
        double maiorValor = 0;
        
        for (Movimentacao m : movsPessoa) {
            String obs = m.getObs().toLowerCase();
            double valor = Math.max(m.getCredito(), m.getDebito());
            
            if (valor > maiorValor) {
                maiorValor = valor;
                estatisticas.put("maiorOperacao", m);
            }
            
            totalCreditos += m.getCredito();
            totalDebitos += m.getDebito();
            
            if (obs.contains("depósito") || obs.contains("deposito") || m.getCredito() > 0 && m.getDebito() == 0) {
                depositos++;
            } 
            else if (obs.contains("saque") || m.getDebito() > 0 && m.getCredito() == 0 && !obs.contains("transferência")) {
                saques++;
            }
            else if (obs.contains("transferência") || obs.contains("transferencia")) {
                transferencias++;
            }
        }
        
        estatisticas.put("depositos", depositos);
        estatisticas.put("saques", saques);
        estatisticas.put("transferencias", transferencias);
        estatisticas.put("totalCreditos", totalCreditos);
        estatisticas.put("totalDebitos", totalDebitos);
        
        mapaEstatisticas.put(idPessoa, estatisticas);
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
        } else if ("operacoes".equals(ordenarPor)) {
            Collections.sort(pessoas, new Comparator<Pessoa>() {
                public int compare(Pessoa p1, Pessoa p2) {
                    Integer total1 = (Integer) mapaEstatisticas.get(p1.getId()).get("totalOperacoes");
                    Integer total2 = (Integer) mapaEstatisticas.get(p2.getId()).get("totalOperacoes");
                    return ascendente ? 
                        total1.compareTo(total2) : 
                        total2.compareTo(total1);
                }
            });
        }
    }
%>

<div class="container">
    <h1 class="text-center mt-4 mb-4">Histórico de Operações Financeiras</h1>
    
    <!-- Filtros e Ordenação -->
    <div class="card mb-4">
        <div class="card-header bg-primary text-white">
            <h4 class="mb-0">Filtros e Ordenação</h4>
        </div>
        <div class="card-body">
            <form method="get" action="visualizartransacoes.jsp" class="row g-3">
                <div class="col-md-3">
                    <label for="filtroNome" class="form-label">Filtrar por Nome:</label>
                    <input type="text" class="form-control" id="filtroNome" name="filtroNome" 
                           value="<%= filtroNome != null ? filtroNome : "" %>">
                </div>
                <div class="col-md-3">
                    <label for="filtroTipoOperacao" class="form-label">Tipo de Operação:</label>
                    <select class="form-select" id="filtroTipoOperacao" name="filtroTipoOperacao">
                        <option value="todos" <%= filtroTipoOperacao == null || "todos".equals(filtroTipoOperacao) ? "selected" : "" %>>Todos</option>
                        <option value="deposito" <%= "deposito".equals(filtroTipoOperacao) ? "selected" : "" %>>Depósitos</option>
                        <option value="saque" <%= "saque".equals(filtroTipoOperacao) ? "selected" : "" %>>Saques</option>
                        <option value="transferencia" <%= "transferencia".equals(filtroTipoOperacao) ? "selected" : "" %>>Transferências</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label for="ordenarPor" class="form-label">Ordenar por:</label>
                    <select class="form-select" id="ordenarPor" name="ordenarPor">
                        <option value="nome" <%= ordenarPor == null || "nome".equals(ordenarPor) ? "selected" : "" %>>Nome</option>
                        <option value="saldo" <%= "saldo".equals(ordenarPor) ? "selected" : "" %>>Saldo</option>
                        <option value="operacoes" <%= "operacoes".equals(ordenarPor) ? "selected" : "" %>>Nº Operações</option>
                    </select>
                </div>
                <div class="col-md-2">
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
    
    <!-- Botões de Operações -->
    <div class="card mb-4">
        <div class="card-header bg-info text-white">
            <h4 class="mb-0">Operações Financeiras</h4>
        </div>
        <div class="card-body">
            <div class="alert alert-info">
                <i class="glyphicon glyphicon-info-sign"></i> Selecione uma pessoa na tabela abaixo e escolha uma operação para realizar.
            </div>
        </div>
    </div>
    
    <!-- Tabela de Histórico de Operações -->
    <div class="card">
        <div class="card-header bg-dark text-white">
            <h4 class="mb-0">Histórico de Operações por Pessoa</h4>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-striped table-hover">
                    <thead class="table-primary">
                        <tr>
                            <th>ID</th>
                            <th>Nome</th>
                            <th>Resumo de Operações</th>
                            <th>Última Operação</th>
                            <th>Operações</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                        for (Pessoa pessoa : pessoas) { 
                            int idPessoa = pessoa.getId();
                            double saldo = mapaSaldos.get(idPessoa);
                            Map<String, Object> estatisticas = mapaEstatisticas.get(idPessoa);
                            int totalOps = (Integer) estatisticas.get("totalOperacoes");
                            int depositos = (Integer) estatisticas.get("depositos");
                            int saques = (Integer) estatisticas.get("saques");
                            int transferencias = (Integer) estatisticas.get("transferencias");
                            Movimentacao ultimaOp = (Movimentacao) estatisticas.getOrDefault("ultimaOperacao", null);
                        %>
                            <tr>
                                <td><%= pessoa.getId() %></td>
                                <td>
                                <strong><%= pessoa.getNome() %></strong><br>
                                <small class="text-muted">CPF: <%= pessoa.getCpf() %></small><br>
                                <span class="badge <%= saldo < 0 ? "bg-danger" : "bg-success" %>">
                                Saldo: <%= FormatUtils.formatarMoedaBR(saldo) %>
                                </span>
                                </td>

                                <td>
                                    <div class="d-flex justify-content-between">
                                        <span class="badge bg-success">
                                            <i class="glyphicon glyphicon-plus"></i> <%= depositos %> Depósitos
                                        </span>
                                        <span class="badge bg-danger">
                                            <i class="glyphicon glyphicon-minus"></i> <%= saques %> Saques
                                        </span>
                                        <span class="badge bg-warning">
                                            <i class="glyphicon glyphicon-transfer"></i> <%= transferencias %> Transf.
                                        </span>
                                    </div>
                                    <div class="progress mt-2" style="height: 10px;">
                                        <% if (totalOps > 0) { %>
                                            <div class="progress-bar bg-success" role="progressbar" 
                                                 style="width: <%= (depositos * 100.0 / totalOps) %>%;" 
                                                 aria-valuenow="<%= depositos %>" aria-valuemin="0" aria-valuemax="<%= totalOps %>">
                                            </div>
                                            <div class="progress-bar bg-danger" role="progressbar" 
                                                 style="width: <%= (saques * 100.0 / totalOps) %>%;" 
                                                 aria-valuenow="<%= saques %>" aria-valuemin="0" aria-valuemax="<%= totalOps %>">
                                            </div>
                                            <div class="progress-bar bg-warning" role="progressbar" 
                                                 style="width: <%= (transferencias * 100.0 / totalOps) %>%;" 
                                                 aria-valuenow="<%= transferencias %>" aria-valuemin="0" aria-valuemax="<%= totalOps %>">
                                            </div>
                                        <% } %>
                                    </div>
                                    <div class="text-center mt-1">
                                        <small class="text-muted">Total: <%= totalOps %> operações</small>
                                    </div>
                                </td>
                                <td>
                                <% if (ultimaOp != null) { %>
                                <small class="text-muted"><%= sdf.format(ultimaOp.getDataOperacao()) %></small><br>
             <%
            String tipoOp = "";
            String classeOp = "";
            double valor = 0;

            if (ultimaOp.getCredito() > 0) {
                tipoOp = "Crédito";
                classeOp = "text-success";
                valor = ultimaOp.getCredito();
            } else {
                tipoOp = "Débito";
                classeOp = "text-danger";
                valor = ultimaOp.getDebito();
            }
            %>
                            <span class="<%= classeOp %>">
                            <%= tipoOp %>: <%= FormatUtils.formatarMoedaBR(valor) %>
                            </span><br>
                            <small><%= ultimaOp.getObs() %></small>
                            <% } else { %>
                            <span class="text-muted">Nenhuma operação</span>
                            <% } %>
                            </td>
                                <td>
                                    <div class="btn-group-vertical w-100" role="group">
                                        <a href="detalhestransacoes.jsp?id=<%= pessoa.getId() %>" class="btn btn-info btn-sm mb-1">
                                            <i class="glyphicon glyphicon-list-alt"></i> Ver Histórico
                                        </a>
                                        <div class="btn-group" role="group">
                                            <button type="button" class="btn btn-primary btn-sm dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                                <i class="glyphicon glyphicon-cog"></i> Operações
                                            </button>
                                            <div class="dropdown-menu">
                                                <a href="depositar.jsp?id=<%= pessoa.getId() %>" class="dropdown-item">
                                                    <i class="glyphicon glyphicon-plus text-success"></i> Depositar
                                                </a>
                                                <a href="sacar.jsp?id=<%= pessoa.getId() %>" class="dropdown-item">
                                                    <i class="glyphicon glyphicon-minus text-danger"></i> Sacar
                                                </a>
                                                <a href="transferir.jsp?id=<%= pessoa.getId() %>" class="dropdown-item">
                                                    <i class="glyphicon glyphicon-transfer text-warning"></i> Transferir
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    
    <div class="d-flex justify-content-between mt-4 mb-5">
        <div class="pull-left">
                <a href="index.jsp" class="btn btn-default">
                    <i class="glyphicon glyphicon-home"></i> Voltar para a página inicial
                </a>
            </div>
        <a href="historico_geral.jsp" class="btn btn-info">
            <i class="glyphicon glyphicon-time"></i> Ver Histórico Geral
        </a>
    </div>
</div>

<script>
    // Adicionar classes Bootstrap aos elementos existentes
    $(document).ready(function() {
        // Adicionar tooltip aos botões
        $('[data-toggle="tooltip"]').tooltip();
        
        // Ativar dropdowns
        $('.dropdown-toggle').dropdown();
    });
</script>

