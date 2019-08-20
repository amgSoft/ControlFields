package Routine;
#require Routine; 
BEGIN {
    use Exporter();
    @ISA = qw(Exporter);
    @EXPORT = qw($USER_My $PASSWD_My $INSTANCE_My $USER_Or $PASSWD_Or $INSTANCE_Or &crop &mail);
}
    
$USER_My = "mysql_user";
$PASSWD_My = "mysql_pass";
$INSTANCE_My = "DBI:mysql:UTT:127.0.0.1";

$USER_Or = "oracle_user";
$PASSWD_Or = "oracle_pass";
$INSTANCE_Or = "DBI:Oracle:SETT_18";

sub crop($) { my $go=$_[0];$go=~s/^\s+//;$go=~s/\n+$//;$go=~s/\s+$//;return $go; };
#sub crop_tell($) {my $tell=$_[0];$tell =~ s/\D+//g; return $tell;};

sub mail($$) {
      my ($text,$mail) = @_;
      my $msg = MIME::Lite->new (
      From =>'Info Check <UTT_Info@domain.com.>',
      To =>"$mail",
      Subject =>'ATTENTION - NO ENTERED FILL.',
      Type => 'text/plain; charset=UTF-8',
      Data =>"$text"
      );
      $msg->send('smtp',"192.0.0.1",Timeout=>120);
};

      
return 1;
END{}
