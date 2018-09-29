{% if not (theme.duoshuo and theme.duoshuo.shortname) and not theme.duoshuo_shortname %}
  
  {% if theme.gitalk.enable %}
    {% if theme.gitalk.distractionFreeMode  %}      
	  <link rel='stylesheet' href="https://yiyeti.cc/usr/themes/veryse/css/gitalk.css">
      <script src="https://yiyeti.cc/usr/themes/veryse/css/gitalk.min.js"></script>
      <script type="text/javascript">
          var gitalk = new Gitalk({
            clientID:  '{{theme.gitalk.clientID}}', 
            clientSecret: '{{theme.gitalk.clientSecret}}',
            id: window.location.pathname,
            repo: '{{theme.gitalk.repo}}', 
            owner: '{{theme.gitalk.owner}}', 
            admin: '{{theme.gitalk.admin}}', 
            distractionFreeMode: '{{theme.gitalk.distractionFreeMode}}',
          })
          gitalk.render('gitalk-container')
      </script>
    {% endif %}

  {% endif %}
{% endif %}