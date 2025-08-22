<%@page import="uteis.FormatUtils"%>
<%@page import="control.MovimentacaoDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@ include file="static/header.jsp" %>

<%
    try {
        int idPessoa = Integer.parseInt(request.getParameter("idPessoa"));
        double valor = Double.parseDouble(request.getParameter("valor"));
        String obs = request.getParameter("obs");
        
        if (obs == null || obs.trim().isEmpty()) {
            obs = "Saque";
        }
        
        MovimentacaoDAO movDAO = new MovimentacaoDAO();
        boolean sucesso = movDAO.realizarSaque(idPessoa, valor, obs);
        
        if (sucesso) {
%>
          
<script>
        function formatarMoeda(input) {
            let valor = input.value.replace(/\D/g, '');
            if (valor.length > 2) {
                valor = valor.replace(/(\d{2})$/, ',$1');
            }
            if (valor.length > 5) {
                valor = valor.replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1.');
            }
            input.value = 'R$ ' + valor;
        }

        function prepararValor() {
            let valorFormatado = document.getElementById("moeda").value;
            let valorNumerico = valorFormatado.replace(/[^\d,]/g, '').replace(',', '.');
            document.getElementById("valorNumerico").value = valorNumerico;
            return true;
        }
    </script>

<div class="alert alert-success">
                <h3>Saque realizado com sucesso!</h3>
                <p>Valor: <%= FormatUtils.formatarMoedaBR(valor) %></p>
            </div>
<%
        } else {
%>
            <div class="alert alert-danger">
                <h3>Erro ao realizar saque</h3>
                <p>Saldo insuficiente ou ocorreu um erro ao processar a operação.</p>
            </div>
<%
        }
    } catch (Exception e) {
%>
        <div class="alert alert-danger">
            <h3>Erro ao processar a requisição</h3>
            <p><%= e.getMessage() %></p>
        </div>
<%
    }
%>

<div class="mt-3">
    <a href="index.jsp" class="btn btn-primary">Voltar para a página inicial</a>
    <a href="visualizarsaldos.jsp" class="btn btn-secondary">Visualizar saldos</a>
</div>
