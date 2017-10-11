#
# Executes command from defined msg's received from defined senders
# Alexandre Espinosa Menor <aemenor@gmail.com>
#
# Some parts ripped from https://github.com/OMCS/AIMForward
#
# ToDo
#   config, not hard-coded
#
use Purple;

# config
my $EXPECTED_PROTOCOL = 'prpl-jabber'; 
my $EXPECTED_SENDER = 'aemenor@gmail.com'; 

my $EXPECTED_MSG = 'http://xxxxx.xxxxx.com/cgi/xxxxx.xxxx?xxxxxxx=xxxx'; 
my $EXPECTED_MSG_PARSED = '<html xmlns=\'http://jabber.org/protocol/xhtml-im\'><body xmlns=\'http://www.w3.org/1999/xhtml\'><p><a href=\'URL\'>url&amp;&url</a></p></body></html>';

my $COMMAND_TO_EXEC = 'ssh alex@xxxxxxx "apt update -q && apt upgrade -y"';


%PLUGIN_INFO = (
    perl_api_version => 2,
    name => "Execute command from MSG parsed",
    version => "0.1",
    summary => "Executes command from defined msg's received from defined senders.",
    description => "Executa comandos parseando certas mensagens de certos chats.",
    author => "Alexandre Espinosa Menor <aemenor\@gmail.com",
    url => "https://github.com/alexandregz/execCmdFromParsedMsgsPidgin",
    load => "plugin_load",
    unload => "plugin_unload"
);

sub plugin_init {
    return %PLUGIN_INFO;
}

sub plugin_load {
    my $plugin = shift;
    Purple::Debug::info("execCmdsFromParsedMsgs", "plugin_load() - execCmdsFromParsedMsgs Loaded.\n");
    #Purple::Notify::message($plugin,1,"randomator","plugin_load(): message 1 ", "plugin_load(): message 2\n", NULL, NULL);

    # Connect to the conversation list exposed by libpurple
    my $conversations = Purple::Conversations::get_handle();

    # Connect the conv_received_msg function to the received-im-msg signal, this function will be called whenever new messages come in
    Purple::Signal::connect($conversations, "received-im-msg", $plugin, \&conv_received_msg, "received im message");

}

sub plugin_unload {
    my $plugin = shift;
    Purple::Debug::info("execCmdsFromParsedMsgs", "plugin_unload() - execCmdsFromParsedMsgs Unloaded.\n");
    #Purple::Notify::message($plugin,1,"randomator","plugin_unload(): message 1 ", "plugin_unload(): message 2\n", NULL, NULL);
}


# This function will be called whenever a message is received
sub conv_received_msg
{
    # Access variables passed in from signal
    my ($account, $sender, $message, $conv, $flags, $data) = @_;

    # Check if the message received is using the AIM protocol and sent by the expected sender 
    if ($account->get_protocol_id() eq $EXPECTED_PROTOCOL && $sender =~ /^$EXPECTED_SENDER/ && 
            ($message eq $EXPECTED_MSG || $message eq $EXPECTED_MSG_PARSED)
       )
    {
        #Purple::Debug::info("execCmdsFromParsedMsgs", "executando [$COMMAND_TO_EXEC]\n");
        my $output = `$COMMAND_TO_EXEC`;

        if($conv) {
            my $im = $conv->get_im_data();

            $output =~ s/\s+$//;
            $im->send($output);
        }
    }

    return;
}

1;


