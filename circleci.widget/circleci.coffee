CIRCLECI_TOKEN   = 'YOUR_TOKEN_HERE'
SHOW_BUILD_COUNT = 5

colors =
  standard: '#525252'
  queued  : '#999999'
  running : '#525252'
  success : '#80b95b'
  failed  : '#ff1e7a'
  fixed   : '#80b95b'

command: "curl -sS -H 'Accept: application/json' 'https://circleci.com/api/v1/recent-builds?circle-token=#{ CIRCLECI_TOKEN }&limit=#{ SHOW_BUILD_COUNT }'"

refreshFrequency: 30000

style: """
  top: 20px
  left: 4px
  margin: 0 auto
  font-family: Myriad Set Pro, Helvetica Neue
  font-weight: 300
  font-smoothing: antialias

  td
    padding: 4px 8px
    font-size: 14px
    color: #{colors.standard}

    .status
      margin: 2px 0
      padding: 0
      font-size: 12px
      font-weight: normal

    .project
      font-size: 11px
      font-weight: normal
      vertical-align: 2px
      margin-left: 4px
      font-family: Ubuntu Mono, Menlo
      opacity: 0.8

  .build_status .status
    width: 21px
    height: 21px
    border: 2px solid
    border-radius: 100%

  .not_running .status
    border-color: #{colors.queued}
    color:  #{colors.queued}

  .running .status
    border-color: rgba(#{colors.running}, 0.2)
    color: #{colors.running}
    border-top-color: #{colors.running}

  .running .build_status .status
    animation: spin 1s infinite
    animation-timing-function: linear

  .fixed .status
    border-color: #{colors.fixed}
    color: #{colors.fixed}

  .fixed .build_status .status
    background: rgba(#{colors.fixed}, 0.1)

  .success .status
    border-color: #{colors.success}
    color: #{colors.success}

  .success .build_status .status
    background: rgba(#{colors.success}, 0.1)

  .failed .status
    border-color: #{colors.failed}
    color: #{colors.failed}

  .failed .build_status .status
    background: rgba(#{colors.failed}, 0.1)

  .canceled
    opacity: 0.5

    .branch
      text-decoration: line-through
"""

render: -> """
  <div>
    <style>
      @-webkit-keyframes spin {
        from {
          -webkit-transform: rotate(0deg);
        }
        to {
          -webkit-transform: rotate(360deg);
        }
      }
    </style>
    <table></table>
  </div>
"""

update: (output, domEl) ->
  builds = JSON.parse(output)
  table  = $(domEl).find('table')

  # Reset the table
  table.html('')

  humanizeStatus = (status) ->
    status = 'queued' if status == 'not_running'
    status = build.author_name + ' broke it' if status == 'failed'

    status

  renderBuild = (build) ->
    """
    <tr class="#{ build.status }">
      <td class="build_status"><div class="status"></div></td>
      <td class="build_branch">
        <span class='branch'>#{ build.branch }</span> <span class='project'>#{build.reponame}</span>
        <p class='status'>
          <span class='build-num'>##{ build.build_num }</span>
          #{ humanizeStatus(build.status) }
        </p>
      </td>
    </tr>
    """

  for build in builds
    table.append renderBuild(build)
