CIRCLECI_TOKEN = 'YOUR_TOKEN_HERE'
SHOW_BUILD_COUNT = 5

command: "curl -s -H 'Accept: application/json' 'https://circleci.com/api/v1/recent-builds?circle-token=#{ CIRCLECI_TOKEN }&limit=#{ SHOW_BUILD_COUNT }'"

refreshFrequency: 30000

style: """
  bottom: 100px
  left: 60px
  margin: 0 auto
  color: #3a3a3a
  font-family: Helvetica Neue
  font-weight: 300
  font-smoothing: antialiased

  table

    td
      padding: 4px 8px
      font-size: 14px

      .status
        margin: 2px 0
        padding: 0
        font-size: 13px
        font-weight: normal

      .project
        font-size: 11px
        color: #3a3a3a
        font-weight: normal
        vertical-align: 2px
        margin-left: 4px
        font-family: Menlo

    .build_status .status
      width: 21px
      height: 21px
      border: 2px solid
      border-radius: 100%

    .not_running .status
      border-color: #aaa
      color: #aaa

    .running .status
      border-color: rgba(#fff, 0.2)
      color: #3a3a3a
      border-top-color: #f0f0f0

    .running .build_status .status
      animation: spin 1s infinite
      animation-timing-function: linear

    .fixed .status
      border-color: #f7b441
      color: #dfa971

    .fixed .build_status .status
      background: rgba( #dfa971, 0.1)

    .success .status
      border-color: #80b95b
      color:  #80b95b

    .success .build_status .status
      background: rgba(#80b95b, 0.1)

    .failed .status
      border-color: #ff1e7a
      color: #ff1e7a

    .failed .build_status .status
      background: rgba(#ff1e7a, 0.1)

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
  console.log output
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
