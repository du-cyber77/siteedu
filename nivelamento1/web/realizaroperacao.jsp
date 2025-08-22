<%@page import="java.util.ArrayList"%>
<%@ page import="control.PessoaDAO, control.MovimentacaoDAO" %>
<%@ page import="java.text.DecimalFormat" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="static/header.jsp" %>

<center>
<%
    String operacao = request.getParameter("operacao");
    MovimentacaoDAO movDAO = new MovimentacaoDAO();
    boolean sucesso = false;

    if ("depositar".equals(operacao)) {
        int id = Integer.parseInt(request.getParameter("id"));
        double valor = Double.parseDouble(request.getParameter("valor"));
        // Novo método unificado
        sucesso = movDAO.inserirMovimentacao(id, null, valor, "deposito", "Depósito via formulário");
    } 
    else if ("sacar".equals(operacao)) {
        int id = Integer.parseInt(request.getParameter("id"));
        double valor = Double.parseDouble(request.getParameter("valor"));
        // Novo método unificado
        sucesso = movDAO.inserirMovimentacao(id, null, valor, "saque", "Saque via formulário");
    } 
    else if ("transferir".equals(operacao)) {
        int deId = Integer.parseInt(request.getParameter("deId"));
        int paraId = Integer.parseInt(request.getParameter("paraId"));
        double valor = Double.parseDouble(request.getParameter("valor"));
        // Novo método unificado
        sucesso = movDAO.inserirMovimentacao(deId, paraId, valor, "transferencia", "Transferência via formulário");
    }
    
    if (sucesso) {
%>
        <div style="color: green; margin: 20px;">
            <h3>Operação <%= operacao %> realizada com sucesso!</h3>
            <p>Valor: R$ <%= request.getParameter("valor") %></p>
        </div>
<%
    } else {
%>
        <div style="color: red; margin: 20px;">
            <h3>Erro ao realizar a operação <%= operacao %>.</h3>
            <p>Verifique se há saldo suficiente ou se os dados estão corretos.</p>
        </div>
<%
    }
%>

<div style="margin-top: 20px;">
    <a href="index.jsp">Voltar para a página inicial</a> | 
    <a href="visualizartransacoes.jsp">Ver todas as transações</a>
</div>
</center>
