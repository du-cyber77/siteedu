<%@page import="uteis.FormatUtils"%>
<%@page import="model.Movimentacao, model.Pessoa"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="control.MovimentacaoDAO, control.PessoaDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="static/header.jsp" %>

<%
    int idPessoa = Integer.parseInt(request.getParameter("id"));
    
    PessoaDAO pessoaDAO = new PessoaDAO();
    Pessoa pessoa = pessoaDAO.buscarPessoaPorId(idPessoa);
    
    MovimentacaoDAO movDAO = new MovimentacaoDAO();
    ArrayList<Movimentacao> movimentacoes = movDAO.listarMovimentacoesPorPessoa(idPessoa);
    
    double saldo = movDAO.calcularSaldoPorPessoa(idPessoa);
    
    // Formatar datas com horário completo
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
%>

<center>
    <h1>Sistema de Controle Financeiro - Detalhes de Transações</h1>
    
    <div style="margin: 20px; text-align: left; width: 80%;">
        <h2>Dados da Conta</h2>
        <p><strong>Nome:</strong> <%= pessoa.getNome() %></p>
        <p><strong>CPF:</strong> <%= pessoa.getCpf() %></p>
        <p><strong>Saldo Atual:</strong> <span style="<%= saldo < 0 ? "color: red;" : "" %>"><%= FormatUtils.formatarMoedaBR(saldo) %></span></p>
    </div>
    
    <h2>Histórico de Movimentações</h2>
    
    <% if (movimentacoes.isEmpty()) { %>
        <p>Nenhuma movimentação encontrada para esta pessoa.</p>
    <% } else { %>
        <table border="1" style="width: 80%; margin-top: 20px; border-collapse: collapse;">
            <thead>
                <tr style="background-color: #f2f2f2;">
                    <th>Data e Hora</th>
                    <th>Tipo</th>
                    <th>Crédito</th>
                    <th>Débito</th>
                    <th>Observação</th>
                </tr>
            </thead>
            <tbody>
                <% for (Movimentacao mov : movimentacoes) { %>
                    <tr>
                        <td><%= sdf.format(mov.getDataOperacao()) %></td>
                        <td>
                            <% if (mov.getCredito() > 0) { %>
                                <span style="color: green;">Entrada</span>
                            <% } else { %>
                                <span style="color: red;">Saída</span>
                            <% } %>
                        </td>
                        <td style="text-align: right;">
                            <% if (mov.getCredito() > 0) { %>
                                <%= FormatUtils.formatarMoedaBR(mov.getCredito()) %>
                            <% } else { %>
                                -
                            <% } %>
                        </td>
                        <td style="text-align: right;">
                            <% if (mov.getDebito() > 0) { %>
                                <%= FormatUtils.formatarMoedaBR(mov.getDebito()) %>
                            <% } else { %>
                                -
                            <% } %>
                        </td>
                        <td><%= mov.getObs() %></td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    <% } %>
    
    <div style="margin-top: 20px;">
        <a href="visualizarsaldos.jsp">Voltar para lista de saldos</a>
    </div>
</center>
