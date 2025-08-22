<%-- transferir.jsp --%>
<%@ include file="static/header.jsp" %>
<%@ page import="control.PessoaDAO, control.MovimentacaoDAO, java.util.List, model.Pessoa" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    int idPessoaOrigem = Integer.parseInt(request.getParameter("id"));
    PessoaDAO pessoaDAO = new PessoaDAO();
    List<Pessoa> pessoas = pessoaDAO.listaPessoas();
    
    // Obter saldo atual para exibir
    MovimentacaoDAO movDAO = new MovimentacaoDAO();
    double saldoAtual = movDAO.calcularSaldoPorPessoa(idPessoaOrigem);
    
    // Obter nome da pessoa de origem
    Pessoa pessoaOrigem = pessoaDAO.buscarPessoaPorId(idPessoaOrigem);
%>

<center>
    <h1>Sistema de Controle Financeiro - Transferência</h1>

    
    
    <div style="margin-bottom: 20px;">
        <strong>Origem:</strong> <%= pessoaOrigem.getNome() %><br>
        <strong>Saldo disponível:</strong> R$ <%= String.format("%.2f", saldoAtual) %>
    </div>
    
    <form action="realizaroperacao.jsp" method="post" onsubmit="return prepararValor();">
        <!-- ID da pessoa origem (vindo da URL) -->
        <input type="hidden" name="deId" value="<%= idPessoaOrigem %>">
        
        <!-- Tipo da operação -->
        <input type="hidden" name="operacao" value="transferir">
        
        <label for="paraId">Transferir para:</label><br>
        <select name="paraId" id="paraId" required>
            <option value="">Selecione o destinatário</option>
            <% for (Pessoa p : pessoas) {
                   if (p.getId() != idPessoaOrigem) { %>
                <option value="<%= p.getId() %>"><%= p.getNome() %></option>
            <% } } %>
        </select>
        
        <br><br>
        <label for="moeda">Valor (R$):</label><br>
        <input type="text" id="moeda" name="valorFormatado" placeholder="R$ 0,00" oninput="formatarMoeda(this)" required />
        <input type="hidden" id="valorNumerico" name="valor" />

        <br><br>
        <input type="submit" value="Transferir">
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


<%-- 
    Document   : transferir
    Created on : 14 de mai. de 2025, 21:49:55
    Author     : Eduardo Almeida
--%>

