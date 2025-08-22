<%@page import="model.Pessoa"%>
<%@page import="control.PessoaDAO"%>
<%@page import="java.util.ArrayList"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@ include file="static/header.jsp" %>

<%
    // Configurações de Paginação
    int paginaAtual = 1;
    int registrosPorPagina = 10; // Defina quantos registros por página
    String filtroNome = request.getParameter("filtroNome");
    if (filtroNome == null) {
        filtroNome = ""; // Garante que não seja nulo
    }

    // Obter número da página da requisição
    String paginaParam = request.getParameter("pagina");
    if (paginaParam != null && !paginaParam.isEmpty()) {
        try {
            paginaAtual = Integer.parseInt(paginaParam);
            if (paginaAtual < 1) {
                paginaAtual = 1;
            }
        } catch (NumberFormatException e) {
            paginaAtual = 1; // Valor padrão em caso de erro
        }
    }

    // Buscar dados paginados e contagem total
    PessoaDAO pessoaDAO = new PessoaDAO();
    ArrayList<Pessoa> listaPessoas = pessoaDAO.listaPessoasPaginado(paginaAtual, registrosPorPagina, filtroNome);
    int totalRegistros = pessoaDAO.countPessoas(filtroNome);
    int totalPaginas = (int) Math.ceil((double) totalRegistros / registrosPorPagina);

    // Ajustar página atual se for maior que o total de páginas
    if (paginaAtual > totalPaginas && totalPaginas > 0) {
        paginaAtual = totalPaginas;
        // Recarregar dados para a última página válida
        listaPessoas = pessoaDAO.listaPessoasPaginado(paginaAtual, registrosPorPagina, filtroNome);
    }
%>

<div class="container mt-4">
    <h1 class="text-center mt-4 mb-4">Sistema de Controle Financeiro - Listagem de Pessoas</h1>

    <!-- Formulário de Filtro -->
    <form action="listartodaspessoas.jsp" method="get" class="mb-4">
        <div class="row">
            <div class="col-md-6 offset-md-3">
                <div class="input-group">
                    <input type="text" class="form-control" name="filtroNome" placeholder="Filtrar por nome..." value="<%= filtroNome %>">
                    <span class="input-group-btn">
                        <button class="btn btn-primary" type="submit">Filtrar</button>
                    </span>
                </div>
            </div>
        </div>
    </form>

    <% if (listaPessoas.isEmpty()) { %>
        <div class="alert alert-info text-center">Nenhuma pessoa encontrada com o filtro aplicado.</div>
    <% } else { %>
        <div class="table-responsive">
            <table class="table table-striped table-hover table-bordered align-middle text-center shadow rounded">
                <thead class="table-light">
                    <tr>
                        <th scope="col">ID</th>
                        <th scope="col">Nome</th>
                        <th scope="col">Telefone</th>
                        <th scope="col">CPF</th>
                        <th scope="col">Endereço</th>
                        <th scope="col">Detalhes</th>
                        <th scope="col">Operações</th>
                    </tr>
                </thead>
                <tbody class="table-group-divider">
                    <% for (Pessoa pessoa : listaPessoas) { %>
                    <tr>
                        <td><%= pessoa.getId() %></td>
                        <td class="text-start"><%= pessoa.getNome() %></td>
                        <td class="text-nowrap"><%= pessoa.getTelefone() %></td> <%-- Já formatado pelo DAO --%>
                        <td class="text-nowrap"><%= pessoa.getCpf() %></td> <%-- Já formatado pelo DAO --%>
                        <td class="text-start"><%= pessoa.getEndereco() %></td>
                        <td>
                            <form action="detalhespessoa.jsp" method="POST" style="display: inline;">
                                <input type="hidden" name="id" value="<%= pessoa.getId() %>"/>
                                <button type="submit" class="btn btn-info btn-sm">Ver</button>
                            </form>
                        </td>
                        <td>
                            <div class="d-flex flex-wrap justify-content-center gap-1">
                                <form action="depositar.jsp" method="POST" class="m-0">
                                    <input type="hidden" name="id" value="<%= pessoa.getId() %>"/>
                                    <button type="submit" class="btn btn-success btn-sm">Depositar</button>
                                </form>
                                <form action="sacar.jsp" method="POST" class="m-0">
                                    <input type="hidden" name="id" value="<%= pessoa.getId() %>"/>
                                    <button type="submit" class="btn btn-warning btn-sm">Sacar</button>
                                </form>
                                <form action="transferir.jsp" method="POST" class="m-0">
                                    <input type="hidden" name="id" value="<%= pessoa.getId() %>"/>
                                    <button type="submit" class="btn btn-primary btn-sm">Transferir</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <!-- Controles de Paginação -->
        <% if (totalPaginas > 1) { %>
            <nav aria-label="Page navigation">
                <ul class="pagination justify-content-center">
                    <!-- Botão Anterior -->
                    <li class="page-item <%= (paginaAtual == 1) ? "disabled" : "" %>">
                        <a class="page-link" href="listartodaspessoas.jsp?pagina=<%= paginaAtual - 1 %>&filtroNome=<%= filtroNome %>" aria-label="Previous">
                            <span aria-hidden="true">&laquo;</span>
                        </a>
                    </li>
                    
                    <!-- Números das Páginas (simplificado para mostrar algumas páginas) -->
                    <% 
                        int inicio = Math.max(1, paginaAtual - 2);
                        int fim = Math.min(totalPaginas, paginaAtual + 2);
                        
                        if (inicio > 1) { %>
                            <li class="page-item"><a class="page-link" href="listartodaspessoas.jsp?pagina=1&filtroNome=<%= filtroNome %>">1</a></li>
                            <% if (inicio > 2) { %><li class="page-item disabled"><span class="page-link">...</span></li><% } %>
                        <% }
                        
                        for (int i = inicio; i <= fim; i++) { %>
                            <li class="page-item <%= (i == paginaAtual) ? "active" : "" %>">
                                <a class="page-link" href="listartodaspessoas.jsp?pagina=<%= i %>&filtroNome=<%= filtroNome %>"><%= i %></a>
                            </li>
                        <% } 
                        
                        if (fim < totalPaginas) { %>
                            <% if (fim < totalPaginas - 1) { %><li class="page-item disabled"><span class="page-link">...</span></li><% } %>
                            <li class="page-item"><a class="page-link" href="listartodaspessoas.jsp?pagina=<%= totalPaginas %>&filtroNome=<%= filtroNome %>"><%= totalPaginas %></a></li>
                        <% } %>

                    <!-- Botão Próximo -->
                    <li class="page-item <%= (paginaAtual == totalPaginas) ? "disabled" : "" %>">
                        <a class="page-link" href="listartodaspessoas.jsp?pagina=<%= paginaAtual + 1 %>&filtroNome=<%= filtroNome %>" aria-label="Next">
                            <span aria-hidden="true">&raquo;</span>
                        </a>
                    </li>
                </ul>
            </nav>
        <% } %>
    <% } // Fim do else (se lista não está vazia) %>

    <div class="text-center mt-4 mb-4">
         <a href="index.jsp" class="btn btn-default">
            <i class="glyphicon glyphicon-home"></i> Voltar para a página inicial
        </a>
    </div>

</div> <%-- Fim do container --%>

<%!
    // Funções de formatação removidas pois a formatação agora é feita no DAO
%>
</body>
</html>

