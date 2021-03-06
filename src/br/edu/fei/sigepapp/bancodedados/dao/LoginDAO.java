package br.edu.fei.sigepapp.bancodedados.dao;

/*
 * @(#)LoginDAO.java 0.01 21/02/09
 *
 * Este codigo e parte integrante do projeto de formatura,
 * do curso de ciencias da computacao, do Centro Universitario da FEI
 * Orientado pelo Prof Plinio T. Aquino Jr.
 *
 * Copyright (c) 2009 Equipe SiGePAPP
 * |------------------------------------------------------------------|
 * |                   Modificacoes no Codigo                         |
 * |------------------------------------------------------------------|
 * |   Autor     |   Data      |   Descricao                          |
 * |------------------------------------------------------------------|
 * |   Andrey    | 21/02/09    | Criacao e elaboracao inicial         |
 * |------------------------------------------------------------------|
 * |   Andrey    | 01/03/09    | Criacao do metodo validaLogin        |
 * |------------------------------------------------------------------|
 * |   Andrey    | 03/03/09    | Criacao do metodo finalize da classe |
 * |------------------------------------------------------------------|
 * 
 */

//~-- JDK import --------------------------------------------------------------
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import oracle.jdbc.OracleTypes;
import br.edu.fei.sigepapp.bancodedados.ConnectionFactory;
import br.edu.fei.sigepapp.bancodedados.model.Login;
import br.edu.fei.sigepapp.bancodedados.model.Usuario;
import br.edu.fei.sigepapp.cryptography.Criptografia;
import br.edu.fei.sigepapp.log.GravarLog;

/**
 * 
 * @author Andrey Masiero
 * @version 0.01 21 Fev 2009
 */
public class LoginDAO {

    private Connection conn;

    /**
     * Construtor da classe:- cria uma conex�o com o banco de dados
     * @throws SQLException
     */
    public LoginDAO() throws SQLException {
        this.conn = ConnectionFactory.getConnection();
    }

    /**
     * Metodo que adiciona um registro do Objeto Login no banco de dados
     *
     * @param login
     * @return 1 - Cadastrado / 2 - J� existente / 3 - Erro
     */
    public int insere(Login login) {
        try {
            //Instancia um objeto da classe PreparedStatement com o comando para inser��o do registro no banco
            CallableStatement cstmt = this.conn.prepareCall("begin APPP_INS_TB_LOGIN( ?, ?, ?, ?); end;");

            //Seta os valores para os pontos de interroga��o indexados pela ordem deles na string
            cstmt.setLong(1, login.getCd_user());
            cstmt.setString(2, login.getNm_login());

            String EncryptPassword = Criptografia.escondeSenha(login.getPw_senha());
            cstmt.setString(3, EncryptPassword);
            cstmt.registerOutParameter(4, OracleTypes.NUMBER);

            //executa o comando e fecha a instancia do objeto
            cstmt.execute();
            
            int cResult = (int) cstmt.getInt(4);

            if (cResult == 1) {
                GravarLog.gravaInformacao(LoginDAO.class.getName() + ": inser��o no banco de dados realizada com sucesso");
                cstmt.close();
                return 1;
            } else if(cResult == -1){
                GravarLog.gravaInformacao(LoginDAO.class.getName() + ": Login j� cadastrado");
                cstmt.close();
                return 2;
            }else{
                GravarLog.gravaAlerta(LoginDAO.class.getName() + ": " + cResult + ": erro ao cadastrar novo usu�rio.");
                cstmt.close();
                return 3;
            }
        } catch (SQLException e) {

            //Grava log com o erro que ocorreu durante a execu��o do comando SQL
            GravarLog.gravaErro(LoginDAO.class.getName() + ": erro na inser��o referente a uma exce��o de SQL: " + e.getMessage());

            //Retorno da fun��o como false em caso de erro
            return 3;
        }

    }

    /**
     * Metodo de validacao de login no sistema
     *
     * @param login
     * @param password
     * @return Lista de usuario encontrados na consulta ao banco de dados. Neste caso deve retornar sem um elemento na lista.
     */
    public List<Usuario> validaLogin(String login, String password) {
        try {
            //Cria objeto CallableStatement para receber a procedure que sera executada no BD
            CallableStatement cstmt = this.conn.prepareCall("begin APPP_SEL_LOGIN(?, ?, ?); end;");

            //Associa os valores dos index nos parametros set com os ? da string da procedure
            cstmt.setString(1, login);

            String EncryptPassword = Criptografia.escondeSenha(password);
            cstmt.setString(2, EncryptPassword);
            
            cstmt.registerOutParameter(3, OracleTypes.CURSOR);

            //Executa a procedure
            cstmt.execute();

            //Atribui os resultado da procedure a um objeto ResultSet
            ResultSet rs = (ResultSet) cstmt.getObject(3);

            //Cria um array do objeto Usuario
            List<Usuario> usuarios = new ArrayList<Usuario>();

            //Percorre todos os valores retornados da consulta
            while (rs.next()) {
                //Instancia do objeto Usuario
                Usuario usuario = new Usuario();

                //Atribui os valores do ResultSet aos repectivos campos do objeto Usuario
                usuario.setCd_user(rs.getLong("cd_user"));
                usuario.setNm_prim_nome(rs.getString("nm_prim_nome"));
                usuario.setNm_ult_nome(rs.getString("nm_ult_nome"));
                usuario.setDt_nasc(rs.getDate("dt_nasc"));
                usuario.setNr_nota(rs.getDouble("nr_nota"));
                usuario.setDt_cadastro(rs.getDate("dt_cadastro"));
                usuario.setDs_area_interesse(rs.getString("ds_area_interesse"));
                usuario.setNm_msn(rs.getString("nm_msn"));
                usuario.setNm_skype(rs.getString("nm_skype"));

                //Adiciona o objeto usuario a lista de usuarios
                usuarios.add(usuario);
            }
            //fecha a instancia dos objetos
            rs.close();
            cstmt.close();

            //Grava log com a informa��o de sucesso
            GravarLog.gravaInformacao(LoginDAO.class.getName() + ": pesquisa no banco de dados realizada com sucesso");

            //retorna uma lista com os usuarios selecionados
            return usuarios;
        } catch (SQLException e) {
            //Grava log com o erro que ocorreu durante a execu��o do comando SQL
            GravarLog.gravaErro(LoginDAO.class.getName() + ": erro na pesquisa referente a uma exce��o de SQL: " + e.getMessage());

            //Retorno da fun��o como null em caso de erro
            return null;
        }

    }

    public boolean existeLogin(String login) {
        Integer vResult = new Integer(0);
        try {
            CallableStatement cstmt = this.conn.prepareCall("begin APPP_SEL_EXISTE_LOGIN(?,?); end;");

            cstmt.setString(1, login);
            cstmt.registerOutParameter(2, OracleTypes.INTEGER);

            cstmt.execute();

            vResult = (Integer) cstmt.getObject(2);

            if (vResult == 1) {
                return true;
            } else {
                return false;
            }
        } catch (SQLException e) {
            GravarLog.gravaErro(e.getMessage());
            return false;
        }
    }

    public boolean deleta(Login login){
        try{
            CallableStatement cstmt = this.conn.prepareCall("begin APPP_DEL_LOGIN(? ,?); end;");

            cstmt.setLong(1, login.getCd_user());
            cstmt.registerOutParameter(2, OracleTypes.NUMBER);

            cstmt.execute();

            int cResult = (int) cstmt.getLong(2);

            if (cResult > 0){
                GravarLog.gravaInformacao(LoginDAO.class.getName() + ": login removido com sucesso.");
                cstmt.close();
                return true;
            }else{
                GravarLog.gravaAlerta(LoginDAO.class.getName() + ": problemas durante a remo��o: retorno" + cResult);
                cstmt.close();
                return false;
            }
        }catch(SQLException e){
            GravarLog.gravaErro(LoginDAO.class.getName() + ": erro na execucao do metodo delete: " + e.getSQLState() + " : " + e.getMessage());
            return false;
        }

        
    }

    public int alteraSenha(Login login){
        try{
            CallableStatement cstmt = this.conn.prepareCall("begin APPP_UPD_LOGIN(?,?,?,?); end;");
            if(login.getCd_user() < 1){
                GravarLog.gravaErro(LoginDAO.class.getName() + ": usuario nulo.");
                return 0;
            }else{
                cstmt.setLong(1, login.getCd_user());
            }
            cstmt.setNull(2,OracleTypes.VARCHAR);
            String EncryptPassword = Criptografia.escondeSenha(login.getPw_senha());
            cstmt.setString(3, EncryptPassword);

            cstmt.registerOutParameter(4, OracleTypes.NUMBER);

            cstmt.execute();

            int cResult = (int) cstmt.getLong(4);

            if (cResult != 1){
                GravarLog.gravaErro(LoginDAO.class.getName() + ": erro na atualizacoa do usuario");
                return 0;
            }else{
                GravarLog.gravaErro(LoginDAO.class.getName() + ": atualizacao de usuario com sucesso");
                return 1;
            }
        }catch(SQLException e){
            GravarLog.gravaErro(LoginDAO.class.getName() + ": erro na atualizacao da senha: " + e.getSQLState() + " : " + e.getMessage());
            return 0;
        }
    }

    /**
     * Metodo para fechar o banco de dados da classe
     */
    public void fechaConexao() {
        try {
            if (!this.conn.isClosed()) {
                this.conn.close();
            }
        } catch (SQLException e) {
            GravarLog.gravaErro(LoginDAO.class.getName() + ": erro ao finalizar connexao com o banco: " + e.getMessage());
        }
    }
}
