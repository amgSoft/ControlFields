#!/usr/bin/perl -w

use strict;
use DBI;
use Routine;
use MIME::Lite;
#########################Start program

#установление соединение и подготовка запроса  ORACLE 
my $dbh = DBI->connect($INSTANCE_Or, $USER_Or, $PASSWD_Or, {PrintError => 1, RaiseError => 1, LongReadLen => 64000, LongTruncOk => 0}) or die "??? ??????? ? ???? oracle\n";
my $sth = $dbh->prepare(qq{select nm_recepient,num_tnode from as.rnt_tnodes_ss07});
$sth->execute() or die "$sth->errstr";

#установка соединения и подготовка запросов MYSQL 
my $dbh_m = DBI->connect($INSTANCE_My,$USER_My,$PASSWD_My,{PrintError => 1, RaiseError => 1, LongReadLen => 64000, LongTruncOk => 0}) or die "??? ??????? ? ???? mysql\n";
my $sth_m_1 = $dbh_m->prepare(qq{SELECT id_reg,`e-mail` FROM `my_e-mail_dealers`});
my $sth_m_2 = $dbh_m->prepare(qq{SELECT * FROM UTM5.controlFill_w WHERE id_reg = ?});

$sth_m_1->execute() or die "$sth_m_1->errstr";

#приобразование данных в структуру perl
my $array_ref_ora = $sth->fetchall_arrayref();
my $array_ref_my = $sth_m_1->fetchall_arrayref();
#####################################################

my %bs_reg;

foreach my $row (@$array_ref_ora) {
    my ($id_reg,$id_bs) = @$row;
    $id_reg = substr($id_reg,0,4);
    $bs_reg{$id_bs} = $id_reg;
}

#my ($login,$phone,$id_reg,$contract,$id_bs);

foreach my $row (@$array_ref_my) {
    my ($id_reg,$mail) = @$row;

    my %notFill;
    
    $sth_m_2->execute($id_reg) or die "$sth_m_2->errstr";
    my $array_ref_my_2 = $sth_m_2->fetchall_arrayref();
    
     
    foreach my $data (@$array_ref_my_2) {
        my ($login,$tell,$reg,$contr,$id_bs) = @$data;
    #    print "$login => $tell => $reg => $contr => $id_bs\n";
        my $notFill;
        
        if (!$tell) {
            $tell = "Номер телефона";
            $notFill .= "$tell\n";
        }
        
        if (!$reg) {
            $reg = "Номер региона";
            $notFill .= "$reg\n";
        }
        
        if (!$contr) {
            $contr = "Номер контракта";
            $notFill .= "$contr\n";
        }
        
        unless (exists($bs_reg{$id_bs})) {
            $id_bs = "Номер БС";
            $notFill .= "$id_bs\n";
        }
        $notFill{$login} = $notFill  if (defined($notFill));
    }
#    print "$notFill\n";
    
    my $for_mail = "";
    
    while (my($key,$value) = each(%notFill)) {
        $for_mail .= "$key => $value\n";        
    }
    ############# отправка сообщений ##########################
    &mail
      (
my $text = "
Обратите внимание - для ниже указанных клиентов   
не заполнены или не правильно заполнены следующие данные:
=========================================================
$for_mail",$mail
     ) if (defined($for_mail));
}

exit;
##################################end#########################


