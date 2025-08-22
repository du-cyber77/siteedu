package control;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.Movimentacao;

public class MovimentacaoDAO {

    // Método unificado para depósito, saque e transferência
    public boolean inserirMovimentacao(
        int idPessoaOrigem,
        Integer idPessoaDestino, // null para depósito/saque
        double valor,
        String tipo, // "deposito", "saque", "transferencia"
        String observacao
    ) {
        if (valor <= 0) return false;

        // Verifica saldo para saque e transferência
        if ("saque".equalsIgnoreCase(tipo) || "transferencia".equalsIgnoreCase(tipo)) {
            double saldoAtual = calcularSaldoPorPessoa(idPessoaOrigem);
            if (saldoAtual < valor) {
                return false; // Saldo insuficiente
            }
        }

        if ("transferencia".equalsIgnoreCase(tipo)) {
            Connection conn = null;
            boolean sucesso = false;
            try {
                conn = Conexao.conectar();
                conn.setAutoCommit(false);

                // Débito na origem
                Movimentacao movOrigem = new Movimentacao();
                movOrigem.setIdPessoa(idPessoaOrigem);
                movOrigem.setCredito(0.0);
                movOrigem.setDebito(valor);
                movOrigem.setDataOperacao(new java.util.Date());
                movOrigem.setObs(observacao != null ? "Transferência enviada: " + observacao : "Transferência enviada");

                // Crédito no destino
                Movimentacao movDestino = new Movimentacao();
                movDestino.setIdPessoa(idPessoaDestino);
                movDestino.setCredito(valor);
                movDestino.setDebito(0.0);
                movDestino.setDataOperacao(new java.util.Date());
                movDestino.setObs(observacao != null ? "Transferência recebida: " + observacao : "Transferência recebida");

                String sql = "INSERT INTO movimentacao (idPessoa, Credito, Debito, DataOperacao, OBS) VALUES (?, ?, ?, ?, ?)";

                PreparedStatement pstmOrigem = conn.prepareStatement(sql);
                pstmOrigem.setInt(1, movOrigem.getIdPessoa());
                pstmOrigem.setDouble(2, movOrigem.getCredito());
                pstmOrigem.setDouble(3, movOrigem.getDebito());
                pstmOrigem.setTimestamp(4, new Timestamp(movOrigem.getDataOperacao().getTime()));
                pstmOrigem.setString(5, movOrigem.getObs());
                pstmOrigem.executeUpdate();

                PreparedStatement pstmDestino = conn.prepareStatement(sql);
                pstmDestino.setInt(1, movDestino.getIdPessoa());
                pstmDestino.setDouble(2, movDestino.getCredito());
                pstmDestino.setDouble(3, movDestino.getDebito());
                pstmDestino.setTimestamp(4, new Timestamp(movDestino.getDataOperacao().getTime()));
                pstmDestino.setString(5, movDestino.getObs());
                pstmDestino.executeUpdate();

                conn.commit();
                sucesso = true;

            } catch (SQLException e) {
                if (conn != null) {
                    try {
                        conn.rollback();
                    } catch (SQLException ex) {
                        ex.printStackTrace();
                    }
                }
                e.printStackTrace();
            } finally {
                if (conn != null) {
                    try {
                        conn.setAutoCommit(true);
                        conn.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            }
            return sucesso;
        } else {
            Movimentacao mov = new Movimentacao();
            mov.setIdPessoa(idPessoaOrigem);
            if ("deposito".equalsIgnoreCase(tipo)) {
                mov.setCredito(valor);
                mov.setDebito(0.0);
                mov.setObs(observacao != null ? observacao : "Depósito");
            } else if ("saque".equalsIgnoreCase(tipo)) {
                mov.setCredito(0.0);
                mov.setDebito(valor);
                mov.setObs(observacao != null ? observacao : "Saque");
            } else {
                return false; // Tipo inválido
            }
            mov.setDataOperacao(new java.util.Date());
            return inserirMovimentacaoSimples(mov);
        }
    }

    // Método privado para inserir uma movimentação simples (depósito ou saque)
    private boolean inserirMovimentacaoSimples(Movimentacao mov) {
        String sql = "INSERT INTO movimentacao (idPessoa, Credito, Debito, DataOperacao, OBS) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = Conexao.conectar(); PreparedStatement pstm = conn.prepareStatement(sql)) {
            pstm.setInt(1, mov.getIdPessoa());
            pstm.setDouble(2, mov.getCredito());
            pstm.setDouble(3, mov.getDebito());
            pstm.setTimestamp(4, new Timestamp(mov.getDataOperacao().getTime()));
            pstm.setString(5, mov.getObs());
            int rows = pstm.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Métodos auxiliares e de consulta (mantidos do DAO original)
    public List<Movimentacao> listarMovimentacoes() {
        List<Movimentacao> lista = new ArrayList<>();
        String sql = "SELECT * FROM movimentacao ORDER BY DataOperacao DESC"; // Adicionado ORDER BY
        try (Connection conn = Conexao.conectar(); PreparedStatement pstm = conn.prepareStatement(sql); ResultSet rs = pstm.executeQuery()) {
            while (rs.next()) {
                Movimentacao mov = new Movimentacao();
                mov.setId(rs.getInt("id"));
                mov.setIdPessoa(rs.getInt("idPessoa"));
                mov.setCredito(rs.getDouble("Credito"));
                mov.setDebito(rs.getDouble("Debito"));
                mov.setDataOperacao(rs.getTimestamp("DataOperacao"));
                mov.setObs(rs.getString("OBS"));
                lista.add(mov);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    public boolean deletarTodosMovimentos() {
        String sql = "DELETE FROM movimentacao";
        try (Connection conn = Conexao.conectar(); PreparedStatement pstm = conn.prepareStatement(sql)) {
            int rows = pstm.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public double calcularSaldoPorPessoa(int idPessoa) {
        double saldo = 0.0;
        String sql = "SELECT SUM(Credito) - SUM(Debito) AS saldo FROM movimentacao WHERE idPessoa = ?";

        try (Connection conn = Conexao.conectar(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idPessoa);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                saldo = rs.getDouble("saldo");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return saldo;
    }

    /**
     * Conta o número total de movimentações para uma pessoa específica.
     * @param idPessoa O ID da pessoa.
     * @return O número total de movimentações.
     */
    public int countMovimentacoesPorPessoa(int idPessoa) {
        String sql = "SELECT COUNT(*) FROM movimentacao WHERE idPessoa = ?";
        try (Connection conn = Conexao.conectar(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idPessoa);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Lista as movimentações de uma pessoa de forma paginada.
     * @param idPessoa O ID da pessoa.
     * @param pagina O número da página atual (começando em 1).
     * @param registrosPorPagina O número de registros por página.
     * @return Lista de Movimentacao para a página especificada.
     */
    public ArrayList<Movimentacao> listarMovimentacoesPorPessoaPaginado(int idPessoa, int pagina, int registrosPorPagina) {
        ArrayList<Movimentacao> lista = new ArrayList<>();
        String sql = "SELECT * FROM movimentacao WHERE idPessoa = ? ORDER BY DataOperacao DESC LIMIT ? OFFSET ?";
        int offset = (pagina - 1) * registrosPorPagina;

        try (Connection conn = Conexao.conectar(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idPessoa);
            stmt.setInt(2, registrosPorPagina);
            stmt.setInt(3, offset);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Movimentacao mov = new Movimentacao();
                    mov.setId(rs.getInt("id"));
                    mov.setIdPessoa(rs.getInt("idPessoa"));
                    mov.setCredito(rs.getDouble("Credito"));
                    mov.setDebito(rs.getDouble("Debito"));
                    mov.setDataOperacao(rs.getTimestamp("DataOperacao"));
                    mov.setObs(rs.getString("OBS"));
                    lista.add(mov);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    /**
     * Lista todas as movimentações de uma pessoa (método antigo, agora depreciado).
     * Use listarMovimentacoesPorPessoaPaginado em vez disso.
     */
    @Deprecated
    public ArrayList<Movimentacao> listarMovimentacoesPorPessoa(int idPessoa) {
        // Chama o método paginado com valores padrão para manter compatibilidade
        return listarMovimentacoesPorPessoaPaginado(idPessoa, 1, 1000); // Ex: mostra até 1000 na primeira página
    }

    public boolean excluirMovimentacoesPorPessoa(int idPessoa) {
        String sql = "DELETE FROM movimentacao WHERE idPessoa = ?";
        try (Connection conn = Conexao.conectar(); PreparedStatement pstm = conn.prepareStatement(sql)) {
            pstm.setInt(1, idPessoa);
            int rows = pstm.executeUpdate();
            return true; // Retorna true mesmo se não houver linhas afetadas, pois a operação foi bem-sucedida
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}

