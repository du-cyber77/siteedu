package model;

import java.util.Date;

public class Movimentacao {
    private int id;
    private int idPessoa;
    private double credito;  // Alterado de entrada para credito
    private double debito;   // Alterado de saida para debito
    private Date dataOperacao; // Alterado de dataMovimento para dataOperacao
    private String obs;      // Alterado de tipo para obs

    public Movimentacao() {
    }

    public Movimentacao(int id, int idPessoa, double credito, double debito, Date dataOperacao, String obs) {
        this.id = id;
        this.idPessoa = idPessoa;
        this.credito = credito;
        this.debito = debito;
        this.dataOperacao = dataOperacao;
        this.obs = obs;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getIdPessoa() {
        return idPessoa;
    }

    public void setIdPessoa(int idPessoa) {
        this.idPessoa = idPessoa;
    }

    public double getCredito() {
        return credito;
    }

    public void setCredito(double credito) {
        this.credito = credito;
    }

    public double getDebito() {
        return debito;
    }

    public void setDebito(double debito) {
        this.debito = debito;
    }

    public Date getDataOperacao() {
        return dataOperacao;
    }

    public void setDataOperacao(Date dataOperacao) {
        this.dataOperacao = dataOperacao;
    }

    public String getObs() {
        return obs;
    }

    public void setObs(String obs) {
        this.obs = obs;
    }
    
    // Métodos de compatibilidade para manter código existente funcionando
    // Estes métodos podem ser removidos gradualmente à medida que o código é atualizado
    
    public double getEntrada() {
        return credito;
    }
    
    public void setEntrada(double entrada) {
        this.credito = entrada;
    }
    
    public double getSaida() {
        return debito;
    }
    
    public void setSaida(double saida) {
        this.debito = saida;
    }
    
    public Date getDataMovimento() {
        return dataOperacao;
    }
    
    public void setDataMovimento(Date dataMovimento) {
        this.dataOperacao = dataMovimento;
    }
    
    public String getTipo() {
        return obs;
    }
    
    public void setTipo(String tipo) {
        this.obs = tipo;
    }
}
