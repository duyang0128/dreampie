<#include "/page/layout/_layout.ftl"/>
<@layout activebar="index" html_title=i18n.getText("index.name")>
<script type="text/javascript" src="<@resource.static/>/libs/socket.io/socket.io.min.js"></script>
<script>
    if (!window.console) console = {log: function () {
    }};

    var loginurl = "";

    var pathname = document.location.pathname;

    var lastdot = pathname.lastIndexOf("/");

    if (lastdot > 1) {
        loginurl = pathname.substr(1, lastdot);
    }


    // socket.io specific code
    var socket = io.connect('', {'resource': 'im'});


    var connectedUrl = "";

    socket.on('connect', function () {
        $('#chat').addClass('connected');
        console.log("Connect : " + this.socket.transports);

        $.each(this.socket.transports, function (index, item) {
            $("#transport").append(new Option(item, item));
        });

        connectedUrl = "/" + this.socket.options.resource + "/" + io.protocol + "/" + this.socket.transport.name + "/" + this.socket.sessionid;
        var getDisconnectURL = connectedUrl + "/?t=" + +new Date + "&disconnect";

    });

    socket.on('announcement', function (msg) {
        console.log("announcement=" + msg);
        $('#lines').append($('<p>').append($('<em>').text(msg)));
    });

    socket.on('nicknames', function (nicknames) {
        $('#nicknames').empty().append($('<span>Online: </span>'));
        for (var i in nicknames) {
            console.log("nicknames=" + nicknames[i]);
            $('#nicknames').append($('<b>').text(nicknames[i]));

        }
    });

    socket.on('user message', message);

    socket.on('reconnect', function () {
        $('#lines').remove();
        message('System', 'Reconnected to the server');
    });

    socket.on('disconnect', function () {
        message('System', 'Disconnected');
        console.log("Disconnected");
    });

    socket.on('reconnecting', function () {
        message('System', 'Attempting to re-connect to the server');
    });

    socket.on('error', function (e) {
        message('System', e ? e : 'A unknown error occurred');
    });

    function message(from, msg) {
        console.log("message from =" + from + "  msg = " + msg);
        $('#lines').append($('<p>').append($('<b>').text(from), msg));
    }

    // dom manipulation
    $(function () {
        $('#set-nickname').submit(function (ev) {

            socket.emit('nickname', $('#nick').val(), function (set) {
                console.log("message set = " + set);
                if (!set) {
                    clear();
                    return $('#chat').addClass('nickname-set');

                }
                $('#nickname-err').css('visibility', 'visible');

            });
            return false;

        });

        $('#send-message').submit(function () {
            message('me', $('#message').val());
            socket.emit('user message', $('#message').val());
            clear();
            $('#lines').get(0).scrollTop = 10000000;
            return false;

        });

        function clear() {
            $('#message').val('').focus();

        }

        ;
    });
</script>
</head>


<script>
    $(document).ready(function () {

        $("#transport").change(function () {
            socket.disconnect();
            // pull request 343 : https://github.com/LearnBoost/socket.io-client/pull/343
            io.j = [];
            io.sockets = [];
            socket = io.connect('', {'transports': ['' + $(this).val() + ''], 'resource': 'im'});

        });

        $("#manualDisconnectPost").bind("click", function () {
            var getDisconnectURL = connectedUrl;

            $.post(getDisconnectURL, "0:::", function (data) {
                //alert("Data Loaded: " + data);
            });
        });


    });
</script>


<body>
<div id="chat">
    <div id="nickname">
        <form id="set-nickname" class="wrap">
            <p>Please type in your nickname and press enter.</p>
            <input id="nick">

            <p id="nickname-err">Nickname already in use</p>
        </form>
    </div>
    <div id="connecting">
        <div class="wrap">Connecting to socket.io server</div>
    </div>
    <div id="messages">
        <div id="nicknames"></div>
        <div id="lines"></div>
    </div>
    <form id="send-message">
        <input id="message">
        <button>Send</button>
    </form>
    <div id="transports">
        <select id="transport"></select>

        <div id="manualDisconnectPost">Force Disconnect with Post</div>
    </div>
</div>
</@layout>