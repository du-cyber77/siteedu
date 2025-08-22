<%@page import="model.Pessoa, model.Movimentacao"%>
<%@page import="java.util.ArrayList"%>
<%@page import="control.PessoaDAO, control.MovimentacaoDAO"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="static/header.jsp" %>

<%
    int idPessoa = 0;
    Pessoa pessoa = null;
    double saldo = 0.0;
    ArrayList<Movimentacao> movimentacoes = new ArrayList<>();
    int paginaAtual = 1;
    int registrosPorPagina = 5; // Defina quantas movimentações por página
    int totalRegistros = 0;
    int totalPaginas = 0;
    
    try {
        idPessoa = Integer.parseInt(request.getParameter("id"));
        
        PessoaDAO pessoaDAO = new PessoaDAO();
        pessoa = pessoaDAO.buscarPessoaPorId(idPessoa);
        
        if (pessoa == null) {
            throw new Exception("Pessoa não encontrada.");
        }
        
        MovimentacaoDAO movDAO = new MovimentacaoDAO();
        saldo = movDAO.calcularSaldoPorPessoa(idPessoa);
        
        // Obter página atual para o histórico
        String paginaParam = request.getParameter("paginaHist");
        if (paginaParam != null && !paginaParam.isEmpty()) {
            try {
                paginaAtual = Integer.parseInt(paginaParam);
                if (paginaAtual < 1) {
                    paginaAtual = 1;
                }
            } catch (NumberFormatException e) {
                paginaAtual = 1;
            }
        }
        
        // Buscar movimentações paginadas e contagem total
        movimentacoes = movDAO.listarMovimentacoesPorPessoaPaginado(idPessoa, paginaAtual, registrosPorPagina);
        totalRegistros = movDAO.countMovimentacoesPorPessoa(idPessoa);
        totalPaginas = (int) Math.ceil((double) totalRegistros / registrosPorPagina);
        
        // Ajustar página atual se for maior que o total
        if (paginaAtual > totalPaginas && totalPaginas > 0) {
            paginaAtual = totalPaginas;
            movimentacoes = movDAO.listarMovimentacoesPorPessoaPaginado(idPessoa, paginaAtual, registrosPorPagina);
        }
        
    } catch (NumberFormatException e) {
        // Tratar erro de ID inválido
        request.setAttribute("erro", "ID da pessoa inválido.");
    } catch (Exception e) {
        // Tratar outros erros (ex: pessoa não encontrada)
        request.setAttribute("erro", e.getMessage());
    }
    
    // Formatar datas com horário completo
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
%>

<div class="container">
    <div class="row">
        <div class="col-md-12">
            <%-- Exibir mensagem de erro geral, se houver --%>
            <% String erro = (String) request.getAttribute("erro");
               if (erro != null) { %>
                <div class="alert alert-danger">
                    <i class="glyphicon glyphicon-exclamation-sign"></i> <%= erro %>
                    <br><a href="listartodaspessoas.jsp" class="btn btn-default btn-sm">Voltar para lista</a>
                </div>
            <% } else if (pessoa != null) { %>
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        <h3 class="panel-title"><i class="glyphicon glyphicon-user"></i> Detalhes de: <%= pessoa.getNome() %></h3>
                    </div>
                    <div class="panel-body">
                        <div class="row">
                            <div class="col-md-12">
                                <div class="panel panel-default">
                                    <div class="panel-heading"> 
                                        <h4 class="panel-title">Dados Pessoais</h4>
                                    </div>
                                    <div class="panel-body">
                                        <div class="row">
                                            <div class="col-md-6">
                                                <table class="table table-striped">
                                                    <tr>
                                                        <td style="width: 30%; font-weight: bold;">ID:</td>
                                                        <td><%= pessoa.getId() %></td>
                                                    </tr>
                                                    <tr>
                                                        <td style="font-weight: bold;">Nome:</td>
                                                        <td><%= pessoa.getNome() %></td>
                                                    </tr>
                                                    <tr>
                                                        <td style="font-weight: bold;">CPF:</td>
                                                        <td><%= uteis.FormatUtils.formatarCPF(pessoa.getCpf()) %></td>
                                                    </tr>
                                                </table>
                                            </div>
                                            <div class="col-md-6">
                                                <table class="table table-striped">
                                                    <tr>
                                                        <td style="width: 30%; font-weight: bold;">Telefone:</td>
                                                        <td><%= uteis.FormatUtils.formatarTelefone(pessoa.getTelefone()) %></td>
                                                    </tr>
                                                    <tr>
                                                        <td style="font-weight: bold;">Endereço:</td>
                                                        <td><%= pessoa.getEndereco() %></td>
                                                    </tr>
                                                    <tr>
                                                        <td style="font-weight: bold;">Saldo Atual:</td>
                                                        <td class="<%= saldo < 0 ? "text-danger" : "text-success" %>" style="font-weight: bold;">
                                                            <%= uteis.FormatUtils.formatarMoedaBR(saldo) %>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-12 text-center" style="margin-bottom: 20px;">
                                <div class="btn-group">
                                    <a href="editarpessoa.jsp?id=<%= idPessoa %>" class="btn btn-warning" data-toggle="tooltip" title="Editar dados cadastrais">
                                        <i class="glyphicon glyphicon-edit"></i> Editar
                                    </a>
                                    <button type="button" class="btn btn-danger" onclick="confirmarExclusao(<%= idPessoa %>, '<%= pessoa.getNome().replace("'", "\\'") %>')" data-toggle="tooltip" title="Excluir esta pessoa e todo seu histórico">
                                        <i class="glyphicon glyphicon-trash"></i> Excluir Pessoa
                                    </button>
                                </div>
                                
                                <div class="btn-group">
                                    <button type="button" class="btn btn-success dropdown-toggle" 
                                            data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                        <i class="glyphicon glyphicon-usd"></i> Operações Financeiras <span class="caret"></span>
                                    </button>
                                    <ul class="dropdown-menu">
                                        <li>
                                            <a href="depositar.jsp?id=<%= idPessoa %>">
                                                <i class="glyphicon glyphicon-plus text-success"></i> Depositar
                                            </a>
                                        </li>
                                        <li>
                                            <a href="sacar.jsp?id=<%= idPessoa %>">
                                                <i class="glyphicon glyphicon-minus text-danger"></i> Sacar
                                            </a>
                                        </li>
                                        <li>
                                            <a href="transferir.jsp?id=<%= idPessoa %>">
                                                <i class="glyphicon glyphicon-transfer text-primary"></i> Transferir
                                            </a>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-12">
                                <div class="panel panel-info">
                                    <div class="panel-heading">
                                        <h4 class="panel-title"><i class="glyphicon glyphicon-list"></i> Histórico de Movimentações</h4>
                                    </div>
                                    <div class="panel-body" style="padding: 0;">
                                        <% if (movimentacoes.isEmpty()) { %>
                                            <div class="alert alert-info" style="margin: 15px;">
                                                <i class="glyphicon glyphicon-info-sign"></i> Nenhuma movimentação encontrada para esta pessoa.
                                            </div>
                                        <% } else { %>
                                            <div class="table-responsive">
                                                <table class="table table-striped table-hover" style="margin-bottom: 0;">
                                                    <thead>
                                                        <tr class="active">
                                                            <th>Data/Hora</th>
                                                            <th>Tipo</th>
                                                            <th class="text-right">Crédito</th>
                                                            <th class="text-right">Débito</th>
                                                            <th>Observação</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <% for (Movimentacao mov : movimentacoes) { %>
                                                            <tr>
                                                                <td><%= sdf.format(mov.getDataOperacao()) %></td>
                                                                <td>
                                                                    <% if (mov.getCredito() > 0) { %>
                                                                        <span class="label label-success">Entrada</span>
                                                                    <% } else { %>
                                                                        <span class="label label-danger">Saída</span>
                                                                    <% } %>
                                                                </td>
                                                                <td class="text-right">
                                                                    <% if (mov.getCredito() > 0) { %>
                                                                        <span class="text-success"><%= uteis.FormatUtils.formatarMoedaBR(mov.getCredito()) %></span>
                                                                    <% } else { %>
                                                                        -
                                                                    <% } %>
                                                                </td>
                                                                <td class="text-right">
                                                                    <% if (mov.getDebito() > 0) { %>
                                                                        <span class="text-danger"><%= uteis.FormatUtils.formatarMoedaBR(mov.getDebito()) %></span>
                                                                    <% } else { %>
                                                                        -
                                                                    <% } %>
                                                                </td>
                                                                <td><%= mov.getObs() %></td>
                                                            </tr>
                                                        <% } %>
                                                    </tbody>
                                                </table>
                                            </div>
                                            
                                            <!-- Controles de Paginação do Histórico -->
                                            <% if (totalPaginas > 1) { %>
                                                <div class="panel-footer text-center">
                                                    <nav aria-label="Page navigation">
                                                        <ul class="pagination" style="margin: 0;">
                                                            <!-- Botão Anterior -->
                                                            <li class="page-item <%= (paginaAtual == 1) ? "disabled" : "" %>">
                                                                <a class="page-link" href="detalhespessoa.jsp?id=<%= idPessoa %>&paginaHist=<%= paginaAtual - 1 %>" aria-label="Previous">
                                                                    <span aria-hidden="true">&laquo;</span>
                                                                </a>
                                                            </li>
                                                            
                                                            <!-- Números das Páginas -->
                                                            <% 
                                                                int inicio = Math.max(1, paginaAtual - 2);
                                                                int fim = Math.min(totalPaginas, paginaAtual + 2);
                                                                
                                                                if (inicio > 1) { %>
                                                                    <li class="page-item"><a class="page-link" href="detalhespessoa.jsp?id=<%= idPessoa %>&paginaHist=1">1</a></li>
                                                                    <% if (inicio > 2) { %><li class="page-item disabled"><span class="page-link">...</span></li><% } %>
                                                                <% }
                                                                
                                                                for (int i = inicio; i <= fim; i++) { %>
                                                                    <li class="page-item <%= (i == paginaAtual) ? "active" : "" %>">
                                                                        <a class="page-link" href="detalhespessoa.jsp?id=<%= idPessoa %>&paginaHist=<%= i %>"><%= i %></a>
                                                                    </li>
                                                                <% } 
                                                                
                                                                if (fim < totalPaginas) { %>
                                                                    <% if (fim < totalPaginas - 1) { %><li class="page-item disabled"><span class="page-link">...</span></li><% } %>
                                                                    <li class="page-item"><a class="page-link" href="detalhespessoa.jsp?id=<%= idPessoa %>&paginaHist=<%= totalPaginas %>"><%= totalPaginas %></a></li>
                                                                <% } %>

                                                            <!-- Botão Próximo -->
                                                            <li class="page-item <%= (paginaAtual == totalPaginas) ? "disabled" : "" %>">
                                                                <a class="page-link" href="detalhespessoa.jsp?id=<%= idPessoa %>&paginaHist=<%= paginaAtual + 1 %>" aria-label="Next">
                                                                    <span aria-hidden="true">&raquo;</span>
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </nav>
                                                </div>
                                            <% } %>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-12">
                                <a href="listartodaspessoas.jsp" class="btn btn-default">
                                    <i class="glyphicon glyphicon-arrow-left"></i> Voltar para lista de pessoas
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            <% } // Fim do else (se pessoa != null) %>
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

