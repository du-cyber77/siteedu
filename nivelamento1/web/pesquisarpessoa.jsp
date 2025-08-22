<%@page import="control.PessoaDAO"%>
<%@page import="model.Pessoa"%>
<%@page import="java.util.ArrayList"%>
<%@page import="control.MovimentacaoDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="static/header.jsp" %>

<%
    // Inicializar variáveis
    String termo = request.getParameter("termo");
    String filtro = request.getParameter("filtro");
    ArrayList<Pessoa> resultados = new ArrayList<>();
    boolean pesquisaRealizada = false;
    
    // Realizar pesquisa se termo foi fornecido
    if (termo != null && !termo.trim().isEmpty()) {
        pesquisaRealizada = true;
        PessoaDAO pessoaDAO = new PessoaDAO();
        
        // Determinar tipo de filtro
        if (filtro == null || filtro.equals("nome_id")) {
            resultados = pessoaDAO.pesquisarPessoaPorIdOuNome(termo);
        } else if (filtro.equals("cpf")) {
            // Implementação simplificada - na prática, você precisaria adicionar um método específico no DAO
            ArrayList<Pessoa> todasPessoas = pessoaDAO.listaPessoas();
            for (Pessoa p : todasPessoas) {
                if (p.getCpf().replace(".", "").replace("-", "").contains(termo.replace(".", "").replace("-", ""))) {
                    resultados.add(p);
                }
            }
        } else if (filtro.equals("telefone")) {
            // Implementação simplificada - na prática, você precisaria adicionar um método específico no DAO
            ArrayList<Pessoa> todasPessoas = pessoaDAO.listaPessoas();
            for (Pessoa p : todasPessoas) {
                if (p.getTelefone().replace("(", "").replace(")", "").replace("-", "").replace(" ", "").contains(termo.replace("(", "").replace(")", "").replace("-", "").replace(" ", ""))) {
                    resultados.add(p);
                }
            }
        }
    }
    
    // Inicializar MovimentacaoDAO para cálculo de saldos
    MovimentacaoDAO movDAO = new MovimentacaoDAO();
%>

<div class="container mt-4">
    <div class="row">
        <div class="col-md-12">
             <h1 class="text-center mt-4 mb-4">Sistema de Controle Financeiro - Pesquisar Pessoa</h1>
            <div class="panel panel-primary">
                <div class="panel-heading">
                    <h3 class="panel-title"><i class="glyphicon glyphicon-search"></i> Pesquisar Pessoa</h3>
                </div>
                <div class="panel-body">
                    <form id="formPesquisa" action="pesquisarpessoa.jsp" method="get" class="mb-0">
                        <div class="row">
                            <div class="col-md-5">
                                <div class="form-group">
                                    <label for="termo">Termo de Pesquisa:</label>
                                    <div class="input-group">
                                        <span class="input-group-addon"><i class="glyphicon glyphicon-search"></i></span>
                                        <input type="text" class="form-control" name="termo" id="termo" 
                                               placeholder="Digite o termo de pesquisa" 
                                               value="<%= termo != null ? termo : "" %>" required>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label for="filtro">Filtrar por:</label>
                                    <select class="form-control" id="filtro" name="filtro">
                                        <option value="nome_id" <%= filtro == null || filtro.equals("nome_id") ? "selected" : "" %>>Nome ou ID</option>
                                        <option value="cpf" <%= filtro != null && filtro.equals("cpf") ? "selected" : "" %>>CPF</option>
                                        <option value="telefone" <%= filtro != null && filtro.equals("telefone") ? "selected" : "" %>>Telefone</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="form-group">
                                    <label>&nbsp;</label>
                                    <button type="submit" class="btn btn-primary btn-block">
                                        <i class="glyphicon glyphicon-search"></i> Pesquisar
                                    </button>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    <% if (pesquisaRealizada) { %>
        <div class="row" style="margin-top: 20px;">
            <div class="col-md-12">
                <div class="panel panel-success">
                    <div class="panel-heading clearfix">
                        <h3 class="panel-title pull-left"><i class="glyphicon glyphicon-list"></i> Resultados da Pesquisa</h3>
                        <span class="badge pull-right" style="background-color: #fff; color: #5cb85c; margin-top: 2px;"><%= resultados.size() %> pessoa(s) encontrada(s)</span>
                    </div>
                    <div class="panel-body" style="padding: 0;">
                        <% if (resultados.isEmpty()) { %>
                            <div class="alert alert-info" style="margin: 15px;">
                                <i class="glyphicon glyphicon-info-sign"></i> Nenhuma pessoa encontrada com o termo "<%= termo %>".
                            </div>
                        <% } else { %>
                            <div class="table-responsive">
                                <table class="table table-hover table-striped" style="margin-bottom: 0;">
                                    <thead>
                                        <tr class="active">
                                            <th>ID</th>
                                            <th>Nome</th>
                                            <th>CPF</th>
                                            <th>Telefone</th>
                                            <th class="text-right">Saldo</th>
                                            <th class="text-center">Ações</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Pessoa pessoa : resultados) { 
                                            double saldo = movDAO.calcularSaldoPorPessoa(pessoa.getId());
                                        %>
                                            <tr>
                                                <td><%= pessoa.getId() %></td>
                                                <td><%= pessoa.getNome() %></td>
                                                <td><%= pessoa.getCpf() %></td>
                                                <td><%= pessoa.getTelefone() %></td>
                                                <td class="text-right <%= saldo < 0 ? "text-danger" : "text-success" %>" style="font-weight: bold;">
                                                    R$ <%= String.format("%.2f", saldo) %>
                                                </td>
                                                <td class="text-center">
                                                    <div class="btn-group">
                                                        <a href="detalhespessoa.jsp?id=<%= pessoa.getId() %>" 
                                                           class="btn btn-info btn-sm" data-toggle="tooltip" title="Detalhes">
                                                            <i class="glyphicon glyphicon-eye-open"></i>
                                                        </a>
                                                        <a href="editarpessoa.jsp?id=<%= pessoa.getId() %>" 
                                                           class="btn btn-warning btn-sm" data-toggle="tooltip" title="Editar">
                                                            <i class="glyphicon glyphicon-edit"></i>
                                                        </a>
                                                        <button type="button" class="btn btn-danger btn-sm" 
                                                                data-toggle="tooltip" title="Excluir" 
                                                                onclick="confirmarExclusao(<%= pessoa.getId() %>, '<%= pessoa.getNome() %>')">
                                                            <i class="glyphicon glyphicon-trash"></i>
                                                        </button>
                                                    </div>
                                                    
                                                    <div class="btn-group">
                                                        <button type="button" class="btn btn-success btn-sm dropdown-toggle" 
                                                                data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"
                                                                title="Operações">
                                                            <i class="glyphicon glyphicon-usd"></i> <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu dropdown-menu-right">
                                                            <li>
                                                                <a href="depositar.jsp?id=<%= pessoa.getId() %>">
                                                                    <i class="glyphicon glyphicon-plus text-success"></i> Depositar
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="sacar.jsp?id=<%= pessoa.getId() %>">
                                                                    <i class="glyphicon glyphicon-minus text-danger"></i> Sacar
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="transferir.jsp?id=<%= pessoa.getId() %>">
                                                                    <i class="glyphicon glyphicon-transfer text-primary"></i> Transferir
                                                                </a>
                                                            </li>
                                                            <li role="separator" class="divider"></li>
                                                            <li>
                                                                <a href="detalhestransacoes.jsp?id=<%= pessoa.getId() %>">
                                                                    <i class="glyphicon glyphicon-list-alt text-info"></i> Ver Transações
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    <% } %>
    
    <div class="row" style="margin-top: 20px; margin-bottom: 30px;">
        <div class="col-md-12">
            <div class="pull-left"><br><br><br><br><br>
                <a href="index.jsp" class="btn btn-default">
                    <i class="glyphicon glyphicon-home"></i> Voltar para a página inicial
                </a>
            </div>
            <div class="pull-right"><br><br><br><br><br>
                <a href="form_cadastrarpessoa.jsp" class="btn btn-primary">
                    <i class="glyphicon glyphicon-plus"></i> Cadastrar Nova Pessoa
                </a>
            </div>
        </div>
    </div>
</div>

<!-- Modal de Confirmação de Exclusão -->
<div class="modal fade" id="modalConfirmacao" tabindex="-1" role="dialog" aria-labelledby="modalConfirmacaoLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Fechar"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="modalConfirmacaoLabel">Confirmar Exclusão</h4>
            </div>
            <div class="modal-body">
                <p>Tem certeza que deseja excluir a pessoa <strong id="nomePessoa"></strong>?</p>
                <p class="text-danger">Esta ação não pode ser desfeita e também excluirá todas as movimentações financeiras associadas.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Cancelar</button>
                <a href="#" id="btnConfirmarExclusao" class="btn btn-danger">Confirmar Exclusão</a>
            </div>
        </div>
    </div>
</div>

<script>
    // Função para confirmar exclusão
    function confirmarExclusao(id, nome) {
        document.getElementById('nomePessoa').textContent = nome;
        document.getElementById('btnConfirmarExclusao').href = 'excluirpessoa.jsp?id=' + id;
        
        // Mostrar o modal usando jQuery (Bootstrap 3)
        $('#modalConfirmacao').modal('show');
    }
    
    // Inicializar tooltips
    $(document).ready(function() {
        $('[data-toggle="tooltip"]').tooltip();
    });
</script>
