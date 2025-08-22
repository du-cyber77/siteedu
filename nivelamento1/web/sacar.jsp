<%-- sacar.jsp --%>
<%@page import="control.PessoaDAO, control.MovimentacaoDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="static/header.jsp" %>

<%
    int idPessoa = Integer.parseInt(request.getParameter("id"));
    
    // Obter saldo atual para exibir
    MovimentacaoDAO movDAO = new MovimentacaoDAO();
    double saldoAtual = movDAO.calcularSaldoPorPessoa(idPessoa);
%>

<center>
    <h1>Sistema de Controle Financeiro - Saque</h1>

    
    
    <div style="margin-bottom: 20px;">
        <strong>Saldo disponível:</strong> R$ <%= String.format("%.2f", saldoAtual) %>
    </div>
    
    <form action="realizaroperacao.jsp" method="post" onsubmit="return prepararValor();">
        <!-- ID da pessoa (vindo da URL) -->
        <input type="hidden" name="id" value="<%= idPessoa %>">

        <!-- Tipo da operação -->
        <input type="hidden" name="operacao" value="sacar">

        <label for="moeda">Valor (R$):</label><br>
        <input type="text" id="moeda" name="valorFormatado" placeholder="R$ 0,00" oninput="formatarMoeda(this)" required />
        <input type="hidden" id="valorNumerico" name="valor" />

        <br><br>
        <input type="submit" value="Sacar">
    </form>

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
        <a href="index.jsp" class="btn btn-default">
                    <i class="glyphicon glyphicon-home"></i> Voltar para a página inicial
                </a>
        
</center>
