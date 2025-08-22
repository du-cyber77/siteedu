<%@page import="control.MovimentacaoDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="static/header.jsp" %>

<%
    // Verificar se é uma confirmação
    String confirmacao = request.getParameter("confirmar");
    boolean operacaoRealizada = false;
    boolean sucesso = false;
    
    if ("sim".equals(confirmacao)) {
        operacaoRealizada = true;
        MovimentacaoDAO movDAO = new MovimentacaoDAO();
        sucesso = movDAO.deletarTodosMovimentos();
    }
%>

<center>
    <h1>Sistema de Controle Financeiro - Limpar Movimentações</h1>
    
    <% if (!operacaoRealizada) { %>
        <div style="margin: 20px; color: red;">
            <h2>ATENÇÃO: Esta operação irá excluir TODAS as movimentações do sistema!</h2>
            <p>Esta ação não pode ser desfeita. Todos os registros de transações serão perdidos.</p>
            
            <form action="limpartodamovimentacao.jsp" method="post">
                <input type="hidden" name="confirmar" value="sim">
                <input type="submit" value="Confirmar Exclusão" style="background-color: red; color: white; padding: 10px; margin-top: 20px;">
            </form>
            
            <div style="margin-top: 20px;">
                <a href="visualizarsaldos.jsp">Cancelar e Voltar</a>
            </div>
        </div>
    <% } else { %>
        <div style="margin: 20px; color: <%= sucesso ? "green" : "red" %>;">
            <% if (sucesso) { %>
                <h2>Todas as movimentações foram excluídas com sucesso!</h2>
                <p>Todos os saldos foram zerados.</p>
            <% } else { %>
                <h2>Erro ao excluir movimentações</h2>
                <p>Ocorreu um erro ao tentar excluir as movimentações. Por favor, tente novamente.</p>
            <% } %>
        </div>
        
        <div style="margin-top: 20px;">
            <a href="visualizarsaldos.jsp">Voltar para Visualização de Saldos</a>
        </div>
    <% } %>
</center>

