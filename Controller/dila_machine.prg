DEFINE CLASS dila_machine as Session

  PROCEDURE runmachine  
    *LOCATE zhid1,bh1,sc1,je1,ms1,zh1,my1,fwqbm1,token1,zt1
    *** ��ȡ����
    zhid1=httpqueryparams("userid") && �˻�ID
    bh1=httpqueryparams("code")  && �������
    
    *** ��machine ��ѯ�����˻���Ϣ-------------------------
    TEXT TO lcSQLCmd NOSHOW TEXTMERGE
      SELECT * FROM machine WHERE code='<<bh1>>'
    ENDTEXT
    oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
 	IF oDBSQLhelper.SQLQuery(lcSQLCmd,"machine")<0
	  ERROR oDBSQLhelper.errmsg
	ENDIF 
    SELECT machine
    GO TOP 
    sc1=timer && ����ʱ����ֵ���ܳ���1440
    je1=money && ���ѽ��
    ms1=seconds && ����
          
    *** ��account��ѯ�˻���Ϣ-------------------------------------
	oDBSQLhelper=NEWOBJECT("MSSQLHelper","MSSQLHelper.prg") 
    IF oDBSQLhelper.SQLQuery("select * from account","account")<0
	  ERROR oDBSQLhelper.errmsg
    ENDIF 
    SELECT account
    GO TOP 
    zh1 = ALLTRIM(account)
    my1 = ALLTRIM(md5key)  && ALLTRIM(MD5(ALLTRIM(key))) && ����Կ��MD5��ʽ���ܣ�
    fwqbm1 = ALLTRIM(num)
    *RETURN cursortojson("account")
	
*!*	    *** ��ѯ�˻�����Ƿ���㣬
*!*		oDBSQLhelper=NEWOBJECT("MSSQLHelper","MSSQLHelper.prg")
*!*		ye1 = oDBSQLhelper.GetSingle(stringformat("SELECT balance FROM [user] WHERE userid={1}",zhid1))
*!*		DO CASE 
*!*		  CASE !EMPTY(oDBSQLHelper.errmsg)
*!*		  ERROR oDBSQLHelper.errmsg
*!*		  CASE ye1=0 OR ye1<je1
*!*		  ERROR "�˻����㣬���ֵ"
*!*		ENDCASE 
    
	*** ����ȡtoken��------------------------------------------
	cUrl="https://twwl.sailafeinav.com/shemachineapi/gettoken/"
	xmlhttp=Createobject("Microsoft.XMLHTTP")
	xmlhttp.Open("POST", ALLTRIM(cUrl), .F.)
	xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	xmlhttp.send("account="+zh1+"&key="+my1)
    cJson = xmlhttp.responseText && �������������ݸ�ֵ��cJson��
	oJSON=foxjson_parse(cJson)
	token1 = ALLTRIM(oJson.item("token"))	
    *RETURN token1
   
     *** ����ȡ����״̬states��------------------------------
	cUrl="https://twwl.sailafeinav.com/shemachineapi/states/"
	xmlhttp=Createobject("Microsoft.XMLHTTP")
	xmlhttp.Open("POST", ALLTRIM(cUrl), .F.)
	xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    xmlhttp.send("token="+token1+"&account="+zh1+"&num="+fwqbm1+"&code="+bh1+"&type=one") 
    cJson1 = xmlhttp.responseText && �������������ݸ�ֵ��cJson��  
    *RETURN cjson1
	oJSON1=foxjson_parse(cJson1)
    zt1=ALLTRIM(oJSON1.item("states").item(1))  && ��ȡ״̬��
	DO CASE 
	  CASE zt1="run"
	  ERROR "������������"
	  CASE zt1="noreg"
	  ERROR "������Ų�����"
	  CASE zt1="error"
	  ERROR "����û������Ҳû������"
*!*	      CASE zt1="link" && 
*!*	      ERROR "�����Ѿ�����"
	ENDCASE 

    *** ����������runmachine��-----------------------------------
	cUrl="https://twwl.sailafeinav.com/shemachineapi/runmachine/"
	xmlhttp=Createobject("Microsoft.XMLHTTP")
	xmlhttp.Open("POST", ALLTRIM(cUrl), .F.)
	xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    xmlhttp.send("token="+token1+"&account="+zh1+"&num="+fwqbm1+"&code="+bh1+"&timer="+ALLTRIM(STR(sc1))) 
    cJson2 = xmlhttp.responseText && �������������ݸ�ֵ��cJson�� 
    * RETURN cJson2 && �ɹ�����   {"msg":"success","code":1}
	oJSON1=foxjson_parse(cJson2)
    cg1=oJSON1.item("code")  && ��ȡ״̬��    
    IF cg1=1
      RETURN '{"errno":0,"errmsg":"ok"}'
    ELSE
      ERROR "����ʧ��"
    ENDIF 
    	    
  ENDPROC

  PROCEDURE restartmachine  
    *** ��ȡ����
    bh1=httpqueryparams("code")  && �������
    
    *** ��machine ��ѯ�����˻���Ϣ-------------------------
    TEXT TO lcSQLCmd NOSHOW TEXTMERGE
      SELECT * FROM machine WHERE code='<<bh1>>'
    ENDTEXT
    oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
 	IF oDBSQLhelper.SQLQuery(lcSQLCmd,"machine")<0
	  ERROR oDBSQLhelper.errmsg
	ENDIF 
    SELECT machine
    GO TOP 
    sc1=0 && timer && ����ʱ����ֵ���ܳ���1440
          
    *** ��account��ѯ�˻���Ϣ-------------------------------------
	oDBSQLhelper=NEWOBJECT("MSSQLHelper","MSSQLHelper.prg") 
    IF oDBSQLhelper.SQLQuery("select * from account","account")<0
	  ERROR oDBSQLhelper.errmsg
    ENDIF 
    SELECT account
    GO TOP 
    zh1 = ALLTRIM(account)
    my1 = ALLTRIM(md5key)  && ALLTRIM(MD5(ALLTRIM(key))) && ����Կ��MD5��ʽ���ܣ�
    fwqbm1 = ALLTRIM(num)
    *RETURN cursortojson("account")

	*** ����ȡtoken��------------------------------------------
	cUrl="https://twwl.sailafeinav.com/shemachineapi/gettoken/"
	xmlhttp=Createobject("Microsoft.XMLHTTP")
	xmlhttp.Open("POST", ALLTRIM(cUrl), .F.)
	xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	xmlhttp.send("account="+zh1+"&key="+my1)
    cJson = xmlhttp.responseText && �������������ݸ�ֵ��cJson��
	oJSON=foxjson_parse(cJson)
	token1 = ALLTRIM(oJson.item("token"))	
    *RETURN token1

    *** ����������restartmachine��-----------------------------------
	cUrl="https://twwl.sailafeinav.com/shemachineapi/runmachine/"
	xmlhttp=Createobject("Microsoft.XMLHTTP")
	xmlhttp.Open("POST", ALLTRIM(cUrl), .F.)
	xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    xmlhttp.send("token="+token1+"&account="+zh1+"&num="+fwqbm1+"&code="+bh1+"&timer="+ALLTRIM(STR(sc1))) 
    cJson2 = xmlhttp.responseText && �������������ݸ�ֵ��cJson�� 
    * RETURN cJson2 && �ɹ�����   {"msg":"success","code":1}
	oJSON1=foxjson_parse(cJson2)
    cg1=oJSON1.item("code")  && ��ȡ״̬��    
    IF cg1=1
      RETURN '{"errno":0,"errmsg":"ok"}'
    ELSE
      ERROR "��������ʧ��"
    ENDIF 
    	    
  ENDPROC

ENDDEFINE 