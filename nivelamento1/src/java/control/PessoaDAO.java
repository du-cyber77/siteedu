package control;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import model.Pessoa;

// Classe responsável pelas operações de banco de dados relacionadas à entidade Pessoa.
public class PessoaDAO {

    // Objeto DAO para operações de movimentação, necessário para operações financeiras consistentes.
    private MovimentacaoDAO movimentacaoDAO = new MovimentacaoDAO();

    /**
     * Cadastra uma nova pessoa no banco de dados.
     * @return true se o cadastro foi bem-sucedido, false caso contrário.
     */
    public boolean cadastrarPessoa(Pessoa pessoa) {
        String sql = "INSERT INTO pessoas (nome, telefone, cpf, endereco) VALUES (?, ?, ?, ?)";
        
        try (Connection con = Conexao.conectar(); PreparedStatement pstm = con.prepareStatement(sql)) {
            pstm.setString(1, pessoa.getNome());
            pstm.setString(2, pessoa.getTelefone());
            pstm.setString(3, pessoa.getCpf());
            pstm.setString(4, pessoa.getEndereco());

            int rowsInserted = pstm.executeUpdate();
            if (rowsInserted > 0) {
                System.out.println("✅ Dados inseridos com sucesso.");
                return true;
            }
        } catch (SQLException e) {
            System.err.println("❌ Erro ao cadastrar pessoa: " + e.getMessage());
        }
        return false;
    }

    /**
     * Conta o número total de pessoas, opcionalmente aplicando um filtro por nome.
     * @param filtroNome O termo para filtrar pelo nome (pode ser null ou vazio para não filtrar).
     * @return O número total de pessoas encontradas.
     */
    public int countPessoas(String filtroNome) {
        String sql = "SELECT COUNT(*) FROM pessoas";
        boolean hasFilter = filtroNome != null && !filtroNome.trim().isEmpty();
        if (hasFilter) {
            sql += " WHERE nome LIKE ?";
        }

        try (Connection con = Conexao.conectar(); PreparedStatement pstm = con.prepareStatement(sql)) {
            if (hasFilter) {
                pstm.setString(1, "%" + filtroNome + "%");
            }
            try (ResultSet rs = pstm.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("Erro ao contar pessoas: " + e);
        }
        return 0;
    }

    /**
     * Lista pessoas de forma paginada, opcionalmente aplicando um filtro por nome e ordenando por nome.
     * @param pagina O número da página atual (começando em 1).
     * @param registrosPorPagina O número de registros a serem exibidos por página.
     * @param filtroNome O termo para filtrar pelo nome (pode ser null ou vazio para não filtrar).
     * @return Lista de Pessoas para a página especificada.
     */
    public ArrayList<Pessoa> listaPessoasPaginado(int pagina, int registrosPorPagina, String filtroNome) {
        ArrayList<Pessoa> listaPessoa = new ArrayList<>();
        // Base SQL com formatação de telefone e CPF
        String sqlBase = "SELECT id, nome, " +
                         "CONCAT('(', SUBSTRING(telefone, 1, 2), ') ', SUBSTRING(telefone, 3, 5), '-', SUBSTRING(telefone, 8, 4)) AS telefone, " +
                         "CONCAT(SUBSTRING(cpf, 1, 3), '.', SUBSTRING(cpf, 4, 3), '.', SUBSTRING(cpf, 7, 3), '-', SUBSTRING(cpf, 10, 2)) AS cpf, " +
                         "endereco FROM pessoas";
        String sqlWhere = "";
        String sqlOrderLimit = " ORDER BY nome ASC LIMIT ? OFFSET ?";
        
        boolean hasFilter = filtroNome != null && !filtroNome.trim().isEmpty();
        if (hasFilter) {
            sqlWhere = " WHERE nome LIKE ?";
        }
        
        String sql = sqlBase + sqlWhere + sqlOrderLimit;
        int offset = (pagina - 1) * registrosPorPagina;

        try (Connection con = Conexao.conectar(); PreparedStatement pstm = con.prepareStatement(sql)) {
            int paramIndex = 1;
            if (hasFilter) {
                pstm.setString(paramIndex++, "%" + filtroNome + "%");
            }
            pstm.setInt(paramIndex++, registrosPorPagina);
            pstm.setInt(paramIndex++, offset);

            try (ResultSet rs = pstm.executeQuery()) {
                while (rs.next()) {
                    Pessoa pessoa = new Pessoa();
                    pessoa.setId(rs.getInt("id"));
                    pessoa.setNome(rs.getString("nome"));
                    pessoa.setTelefone(rs.getString("telefone")); // Já formatado
                    pessoa.setCpf(rs.getString("cpf")); // Já formatado
                    pessoa.setEndereco(rs.getString("endereco"));
                    listaPessoa.add(pessoa);
                }
            }
        } catch (SQLException e) {
            System.err.println("Erro ao listar pessoas paginado: " + e);
        }
        return listaPessoa;
    }

    /**
     * Pesquisa pessoas pelo nome (busca parcial). - Mantido para compatibilidade se necessário
     * @return Lista de Pessoas encontradas.
     */
    public ArrayList<Pessoa> pesquisarPessoaPorNome(String nome) {
        ArrayList<Pessoa> listaPessoa = new ArrayList<>();
        String sql = "SELECT id, nome, "
                + "CONCAT('(', SUBSTRING(telefone, 1, 2), ') ', SUBSTRING(telefone, 3, 5), '-', SUBSTRING(telefone, 8, 4)) AS telefone, "
                + "CONCAT(SUBSTRING(cpf, 1, 3), '.', SUBSTRING(cpf, 4, 3), '.', SUBSTRING(cpf, 7, 3), '-', SUBSTRING(cpf, 10, 2)) AS cpf, "
                + "endereco FROM pessoas WHERE nome LIKE ? ORDER BY nome ASC";

        try (Connection con = Conexao.conectar(); PreparedStatement pstm = con.prepareStatement(sql)) {
            pstm.setString(1, "%" + nome + "%");
            ResultSet rs = pstm.executeQuery();

            while (rs.next()) {
                Pessoa pessoa = new Pessoa();
                pessoa.setId(rs.getInt("id"));
                pessoa.setNome(rs.getString("nome"));
                pessoa.setTelefone(rs.getString("telefone"));
                pessoa.setCpf(rs.getString("cpf"));
                pessoa.setEndereco(rs.getString("endereco"));
                listaPessoa.add(pessoa);
            }
        } catch (SQLException e) {
            System.err.println("Erro ao pesquisar pessoa por nome: " + e);
        }
        return listaPessoa;
    }
    
    /**
     * Lista todas as pessoas cadastradas, ordenadas por nome. - Depreciado, usar listaPessoasPaginado
     */
    @Deprecated
    public ArrayList<Pessoa> listaPessoas() {
        // Este método agora chama o método paginado com valores padrão (página 1, muitos registros)
        // para manter a compatibilidade, mas o ideal é usar diretamente o paginado.
        return listaPessoasPaginado(1, 1000, null); // Exemplo: mostra até 1000 na primeira página
    }

    /**
     * Pesquisa pessoas por ID ou nome (busca parcial). - Mantido para compatibilidade se necessário
     * @return Lista de Pessoas encontradas.
     */
    public ArrayList<Pessoa> pesquisarPessoaPorIdOuNome(String termo) {
        ArrayList<Pessoa> listaPessoa = new ArrayList<>();
        String sql = "SELECT id, nome, "
            + "CONCAT('(', SUBSTRING(telefone, 1, 2), ') ', SUBSTRING(telefone, 3, 5), '-', SUBSTRING(telefone, 8, 4)) AS telefone, "
            + "CONCAT(SUBSTRING(cpf, 1, 3), '.', SUBSTRING(cpf, 4, 3), '.', SUBSTRING(cpf, 7, 3), '-', SUBSTRING(cpf, 10, 2)) AS cpf, "
            + "endereco FROM pessoas WHERE nome LIKE ? OR id = ? ORDER BY nome ASC";

        try (Connection con = Conexao.conectar(); PreparedStatement pstm = con.prepareStatement(sql)) {
            pstm.setString(1, "%" + termo + "%");

            try {
                // Tenta converter o termo para int, se falhar, usa -1 (ID inválido)
                int id = Integer.parseInt(termo);
                pstm.setInt(2, id);
            } catch (NumberFormatException e) {
                pstm.setInt(2, -1); // Garante que a busca por ID não retorne nada se o termo não for numérico
            }

            ResultSet rs = pstm.executeQuery();
            while (rs.next()) {
                Pessoa pessoa = new Pessoa();
                pessoa.setId(rs.getInt("id"));
                pessoa.setNome(rs.getString("nome"));
                pessoa.setTelefone(rs.getString("telefone"));
                pessoa.setCpf(rs.getString("cpf"));
                pessoa.setEndereco(rs.getString("endereco"));
                listaPessoa.add(pessoa);
            }
        } catch (SQLException e) {
            System.err.println("Erro ao pesquisar pessoa por ID ou nome: " + e);
        }
        return listaPessoa;
    }
    
    /**
     * Busca uma pessoa específica pelo seu ID.
     * @return Objeto Pessoa se encontrado, null caso contrário.
     */
    public Pessoa buscarPessoaPorId(int id) {
        Pessoa pessoa = null;
        String sql = "SELECT id, nome, telefone, cpf, endereco FROM pessoas WHERE id = ?"; // Busca dados brutos

        try (Connection con = Conexao.conectar(); PreparedStatement pstm = con.prepareStatement(sql)) {
            pstm.setInt(1, id);
            ResultSet rs = pstm.executeQuery();

            if (rs.next()) {
                pessoa = new Pessoa();
                pessoa.setId(rs.getInt("id"));
                pessoa.setNome(rs.getString("nome"));
                pessoa.setTelefone(rs.getString("telefone")); // Dado bruto
                pessoa.setCpf(rs.getString("cpf")); // Dado bruto
                pessoa.setEndereco(rs.getString("endereco"));
            }
        } catch (Exception e) {
            System.err.println("Erro ao buscar pessoa por ID: " + e);
        }
        return pessoa;
    }

    /**
     * Exclui uma pessoa e todas as suas movimentações financeiras do banco de dados.
     * A operação é realizada dentro de uma transação para garantir a atomicidade.
     * @return true se a exclusão (pessoa e movimentações) foi bem-sucedida, false caso contrário.
     */
    public boolean excluirPessoaEHistorico(int id) {
        Connection con = null;
        boolean sucesso = false;
        String sqlDeletePessoa = "DELETE FROM pessoas WHERE id = ?";
        // A exclusão das movimentações será feita pelo MovimentacaoDAO

        try {
            con = Conexao.conectar();
            con.setAutoCommit(false); // Inicia transação

            // 1. Excluir movimentações da pessoa
            boolean movExcluidas = movimentacaoDAO.excluirMovimentacoesPorPessoa(id);
            // Consideramos sucesso mesmo que não haja movimentações a excluir

            // 2. Excluir a pessoa
            try (PreparedStatement stmtPessoa = con.prepareStatement(sqlDeletePessoa)) {
                stmtPessoa.setInt(1, id);
                int resultadoPessoa = stmtPessoa.executeUpdate();
                
                if (resultadoPessoa > 0) {
                    con.commit(); // Confirma a transação se a pessoa foi excluída
                    sucesso = true;
                    System.out.println("✅ Pessoa e seu histórico de movimentações excluídos com sucesso.");
                } else {
                    System.err.println("❌ Pessoa com ID " + id + " não encontrada para exclusão.");
                    con.rollback(); // Desfaz a transação se a pessoa não foi encontrada
                }
            }

        } catch (SQLException e) {
            System.err.println("❌ Erro ao excluir pessoa e histórico: " + e.getMessage());
            if (con != null) {
                try {
                    con.rollback(); // Desfaz a transação em caso de erro
                } catch (SQLException ex) {
                    System.err.println("Erro ao reverter transação: " + ex.getMessage());
                }
            }
        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true); // Restaura auto-commit
                    con.close(); // Fecha a conexão
                } catch (SQLException e) {
                    System.err.println("Erro ao fechar conexão: " + e.getMessage());
                }
            }
        }
        return sucesso;
    }

    /**
     * Atualiza os dados cadastrais de uma pessoa no banco de dados.
     * @param pessoa Objeto Pessoa com os dados atualizados (o ID deve estar presente).
     * @return true se a atualização foi bem-sucedida, false caso contrário.
     */
    public boolean atualizarPessoa(Pessoa pessoa) {
        String sql = "UPDATE pessoas SET nome = ?, telefone = ?, cpf = ?, endereco = ? WHERE id = ?";
        try (Connection conn = Conexao.conectar(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, pessoa.getNome());
            ps.setString(2, pessoa.getTelefone()); // Assume que está sem formatação
            ps.setString(3, pessoa.getCpf()); // Assume que está sem formatação
            ps.setString(4, pessoa.getEndereco());
            ps.setInt(5, pessoa.getId());
            int rowsUpdated = ps.executeUpdate();
            return rowsUpdated > 0;
        } catch (SQLException e) {
            System.err.println("Erro ao atualizar pessoa: " + e.getMessage());
            return false;
        }
    }
    
    // --- Métodos Financeiros Delegados ao MovimentacaoDAO ---
    // Os métodos de saque, depósito e transferência foram removidos desta classe
    // pois a lógica correta e consistente está implementada em MovimentacaoDAO.
    // As chamadas a esses métodos devem ser direcionadas para MovimentacaoDAO.
    // Exemplo: new MovimentacaoDAO().realizarDeposito(pessoaId, valor, "Depósito via sistema");
    
    // --- Métodos Removidos por Inconsistência ---
    // - listarTransacoesPorCpf: Usava tabela 'transacoes' inexistente.
    // - buscarSaldoPorCpf: Usava tabela 'transacoes' inexistente. Usar MovimentacaoDAO.calcularSaldoPorPessoa(id).
    // - registrarTransacao: Usava tabela 'transacoes' inexistente. Usar MovimentacaoDAO.realizarDeposito/Saque.
    // - excluir: Implementação duplicada/inconsistente de exclusão. Usar excluirPessoaEHistorico.
    // - transferir, sacar, depositar: Lógica incorreta que atualizava 'saldo' na tabela 'pessoas'.

    // Método main removido pois era apenas para teste interno da classe.
}

