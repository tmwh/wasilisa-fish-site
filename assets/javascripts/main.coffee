---
---

$body = $('body')
user_agent_parser = new UAParser
current_device = user_agent_parser.getDevice()
is_mobile_device = current_device.type == 'mobile' || current_device.type == 'tablet'
$menu_button = $('#menu-button')
$content_wrapper = $('#content-wrapper')
$picture_wrapper = $('#picture-wrapper')

add_hammer_event_to = ($elements, event, callback) ->
  $elements.each (i, el)->
    $el = $(el)
    hammer = $el.data('hammer')  || new Hammer(el)
    hammer.on(event, callback)

    hammer.on 'panstart', ->
      $el.addClass('cursor-move')
    hammer.on 'panend', ->
      $el.removeClass('cursor-move')

    $el.data('hammer', hammer)

class PanePanner
  constructor: (@$event_receiver, @$left_pane, @$right_pane)->
    @initial_left_pane_width = @$left_pane.width()
    @initial_right_pane_width = @$right_pane.width()
    @bindings()

  bindings: ->
    add_hammer_event_to @$event_receiver, 'panstart', @save_initial_width
    add_hammer_event_to @$event_receiver, 'panmove', @move_panes
    add_hammer_event_to @$event_receiver, 'panend', @calculate_end_values

  save_initial_width: =>
    @initial_left_pane_width = @$left_pane.width()
    @initial_right_pane_width = @$right_pane.width()
    @disable_transitions()

  move_panes: (e)=>
    return if Math.abs(e.deltaX) < @total_width() * 0.07
    @$left_pane.css('width', @initial_left_pane_width + e.deltaX)
    @$right_pane.css('width', @initial_right_pane_width - e.deltaX)
    @$left_pane.removeClass('full hidden')
    @$right_pane.removeClass('full hidden')

  calculate_end_values: =>
    @enable_transitions()
    unless @open_fullscreen(@$right_pane, @$left_pane)
      unless @open_fullscreen(@$left_pane, @$right_pane)
        @open_halfscreen()
    @$left_pane.css('width', '')
    @$right_pane.css('width', '')

  open_fullscreen: ($full_pane, $hidden_pane)->
    return false unless $full_pane.width() > @total_width() * 0.65

    $full_pane.addClass('full')
    $hidden_pane.addClass('hidden')
    return true

  open_halfscreen: ->
    @$right_pane.addClass('half')
    @$left_pane.addClass('half')

  disable_transitions: ->
    @$left_pane.addClass('notransition')
    @$right_pane.addClass('notransition')

  enable_transitions: ->
    @$left_pane.removeClass('notransition')
    @$right_pane.removeClass('notransition')

  total_width: ->
    @_total_width ||= @initial_left_pane_width + @initial_right_pane_width

toggle_menu = (close) ->
  if close
    $content_wrapper.removeClass('half').addClass('hidden')
    $picture_wrapper.removeClass('half').addClass('full')
  else
    $picture_wrapper.removeClass('full').addClass('half')
    $content_wrapper.removeClass('hidden').addClass('half')


if $content_wrapper.length > 0 && $picture_wrapper.length > 0
  if window.location.hash == '#content'
    toggle_menu(false)

  $menu_button.click ->
    toggle_menu(!$picture_wrapper.hasClass('full'))

  new PanePanner($body, $picture_wrapper, $content_wrapper)

  unless is_mobile_device
    $('#pick-my-brain').parallax()

$projects_wrapper = $('#projects-wrapper')
if $projects_wrapper.length > 0
  $projects = $('#projects')
  $all_projects = $('.project', $projects_wrapper)
  initial_projects_top = $projects.position().top
  current_project_index = 0
  scroll_projects = (direction)->
    if direction < 0
      ++current_project_index
    else if current_project_index > 0
      --current_project_index

    current_project_index = $all_projects.length - 1 if current_project_index >= $all_projects.length

    $project = $($all_projects[current_project_index])
    new_projects_position = initial_projects_top - $project.position().top
    $projects.css('top', "#{new_projects_position}px")

  setup_swipe_projects_scrolling = ($el)->
    add_hammer_event_to $el, 'swipeup', (e)->
      scroll_projects(-1)
      false

    add_hammer_event_to $el, 'swipedown', (e)->
      scroll_projects(+1)
      false

    $el.data('hammer').get('swipe').set({ direction: Hammer.DIRECTION_ALL })

  $projects_wrapper.on 'mousewheel', (event)->
    scroll_projects(event.deltaY)

  if is_mobile_device
    $projects_wrapper.css('overflow', 'auto')
  else
    setup_swipe_projects_scrolling($projects_wrapper)

