 <%namespace name="ie" file="ie.mako" />

<%
import subprocess
from galaxy.util import sockets

# Sets ID and sets up a lot of other variables
ie_request.load_deploy_config()
ie_request.attr.docker_port = 80

ie_request.launch(env_override={
    'PUB_HTTP_PORT': ie_request.attr.galaxy_config.dynamic_proxy_bind_port,
    'PUB_HOSTNAME': ie_request.attr.HOST,
})

notebook_access_url = ie_request.url_template('${PROXY_URL}/?bam=http://localhost/tmp/bamfile.bam')

root = h.url_for( '/' )
%>
<html>
<head>
    ${ ie.load_default_js() }
</head>
<body>

    <script type="text/javascript">

        ${ ie.default_javascript_variables() }
        var notebook_access_url = '${ notebook_access_url }';
        ${ ie.plugin_require_config() }

        requirejs(['galaxy.interactive_environments', 'plugin/bam_iobio'], function(IES){
            window.IES = IES;
            IES.display_spinner();
        });

        toastr.info(
            "BAM io.bio is starting up!",
            "transferring data ...",
            {'closeButton': true, 'timeOut': 5000, 'tapToDismiss': false}
        );

        var startup = function(){
            // Load notebook
            requirejs(['galaxy.interactive_environments', 'plugin/bam_iobio'], function(IES){
                window.IES = IES;
                IES.load_when_ready(ie_readiness_url, function(){
                    load_notebook(notebook_access_url);
                });
            });

        };
        // sleep 5 seconds
        // this is currently needed to get the vis right
        // plans exists to move this spinner into the container
        setTimeout(startup, 5000);

    </script>
<div id="main">
</div>
</body>
</html>
