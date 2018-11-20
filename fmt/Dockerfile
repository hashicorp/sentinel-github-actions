FROM thrashr888/sentinel-simulator

LABEL "com.github.actions.name"="sentinel fmt"
LABEL "com.github.actions.description"="Format Sentinel policies"
LABEL "com.github.actions.icon"="terminal"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="https://github.com/thrashr888/sentinel-github-actions"
LABEL "homepage"="http://github.com/thrashr888/sentinel-github-actions"
LABEL "maintainer"="Paul Thrasher"

RUN apk --no-cache add jq curl

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]