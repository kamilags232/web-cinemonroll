package negocio;

import persistencia.PessoaDAO;

public class Pessoa {

    private int cdCliente;
    private String nome;
    private String telefone;
    private String email;

    public Pessoa() {}

    public Pessoa(int cdCliente, String nome, String telefone, String email) {
        this.cdCliente = cdCliente;
        this.nome = nome;
        this.telefone = telefone;
        this.email = email;
    }

    public int getCdCliente() {
        return cdCliente;
    }

    public void setCdCliente(int cdCliente) {
        this.cdCliente = cdCliente;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getTelefone() {
        return telefone;
    }

    public void setTelefone(String telefone) {
        this.telefone = telefone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void persistir() throws Exception {
        new PessoaDAO().persistir(this);
    }
}