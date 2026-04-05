`turbo-rails` documentation
===========================

This is the dump of the following links, it is meant to be read by
agents in order to write top notch code according to the Rails Way.

- https://turbo.hotwired.dev/handbook/introduction
- https://turbo.hotwired.dev/handbook/streams
- https://turbo.hotwired.dev/handbook/page_refreshes
- https://turbo.hotwired.dev/handbook/frames
- https://turbo.hotwired.dev/handbook/streams
- https://raw.githubusercontent.com/hotwired/turbo-rails/refs/heads/main/app/helpers/turbo/frames_helper.rb
- https://raw.githubusercontent.com/hotwired/turbo-rails/refs/heads/main/app/helpers/turbo/streams_helper.rb
- https://raw.githubusercontent.com/hotwired/turbo-rails/refs/heads/main/app/models/turbo/streams/tag_builder.rb
- https://raw.githubusercontent.com/hotwired/turbo-rails/refs/heads/main/app/models/concerns/turbo/broadcastable.rb


# Turbo Handbook

Introduction
------------

Turbo bundles several techniques for creating fast, modern, progressively enhanced web applications without using much JavaScript. It offers a simpler alternative to the prevailing client-side frameworks which put all the logic in the front-end and confine the server side of your app to being little more than a JSON API.

With Turbo, you let the server deliver HTML directly, which means all the logic for checking permissions, interacting directly with your domain model, and everything else that goes into programming an application can happen more or less exclusively within your favorite programming language. You’re no longer mirroring logic on both sides of a JSON divide. All the logic lives on the server, and the browser deals just with the final HTML.

You can read more about the benefits of this HTML-over-the-wire approach on the [Hotwire site](https://hotwired.dev/). What follows are the techniques that Turbo brings to make this possible.

[﹟](#turbo-drive%3A-navigate-within-a-persistent-process) Turbo Drive: Navigate within a persistent process
-----------------------------------------------------------------------------------------------------------

A key attraction with traditional single-page applications, when compared with the old-school, separate-pages approach, is the speed of navigation. SPAs get a lot of that speed from not constantly tearing down the application process, only to reinitialize it on the very next page.

Turbo Drive gives you that same speed by using the same persistent-process model, but without requiring you to craft your entire application around the paradigm. There’s no client-side router to maintain, there’s no state to carefully manage. The persistent process is managed by Turbo, and you write your server-side code as though you were living back in the early aughts – blissfully isolated from the complexities of today’s SPA monstrosities!

This happens by intercepting all clicks on `<a href>` links to the same domain. When you click an eligible link, Turbo Drive prevents the browser from following it, changes the browser’s URL using the [History API](https://developer.mozilla.org/en-US/docs/Web/API/History), requests the new page using [`fetch`](https://developer.mozilla.org/en-US/docs/Web/API/fetch), and then renders the HTML response.

Same deal with forms. Their submissions are turned into `fetch` requests from which Turbo Drive will follow the redirect and render the HTML response.

During rendering, Turbo Drive replaces the contents of the `<body>` element and merges the contents of the `<head>` element. The JavaScript window and document objects, and the `<html>` element, persist from one rendering to the next.

While it’s possible to interact directly with Turbo Drive to control how visits happen or hook into the lifecycle of the request, the majority of the time this is a drop-in replacement where the speed is free just by adopting a few conventions.

[﹟](#turbo-frames%3A-decompose-complex-pages) Turbo Frames: Decompose complex pages
-----------------------------------------------------------------------------------

Most web applications present pages that contain several independent segments. For a discussion page, you might have a navigation bar on the top, a list of messages in the center, a form at the bottom to add a new message, and a sidebar with related topics. Generating this discussion page normally means generating each segment in a serialized manner, piecing them all together, then delivering the result as a single HTML response to the browser.

With Turbo Frames, you can place those independent segments inside frame elements that can scope their navigation and be lazily loaded. Scoped navigation means all interaction within a frame, like clicking links or submitting forms, happens within that frame, keeping the rest of the page from changing or reloading.

To wrap an independent segment in its own navigation context, enclose it in a `<turbo-frame>` tag. For example:

```
<turbo-frame id="new_message">
  <form action="/messages" method="post">
    ...
  </form>
</turbo-frame>
```


When you submit the form above, Turbo extracts the matching `<turbo-frame id="new_message">` element from the redirected HTML response and swaps its content into the existing `new_message` frame element. The rest of the page stays just as it was.

Frames can also defer loading their contents in addition to scoping navigation. To defer loading a frame, add a `src` attribute whose value is the URL to be automatically loaded. As with scoped navigation, Turbo finds and extracts the matching frame from the resulting response and swaps its content into place:

```
<turbo-frame id="messages" src="/messages">
  <p>This message will be replaced by the response from /messages.</p>
</turbo-frame>
```


This may sound a lot like old-school frames, or even `<iframe>`s, but Turbo Frames are part of the same DOM, so there’s none of the weirdness or compromises associated with “real” frames. Turbo Frames are styled by the same CSS, part of the same JavaScript context, and are not placed under any additional content security restrictions.

In addition to turning your segments into independent contexts, Turbo Frames affords you:

1.  **Efficient caching.** In the discussion page example above, the related topics sidebar needs to expire whenever a new related topic appears, but the list of messages in the center does not. When everything is just one page, the whole cache expires as soon as any of the individual segments do. With frames, each segment is cached independently, so you get longer-lived caches with fewer dependent keys.
2.  **Parallelized execution.** Each defer-loaded frame is generated by its own HTTP request/response, which means it can be handled by a separate process. This allows for parallelized execution without having to manually manage the process. A complicated composite page that takes 400ms to complete end-to-end can be broken up with frames where the initial request might only take 50ms, and each of three defer-loaded frames each take 50ms. Now the whole page is done in 100ms because the three frames each taking 50ms run concurrently rather than sequentially.
3.  **Ready for mobile.** In mobile apps, you usually can’t have big, complicated composite pages. Each segment needs a dedicated screen. With an application built using Turbo Frames, you’ve already done this work of turning the composite page into segments. These segments can then appear in native sheets and screens without alteration (since they all have independent URLs).

[﹟](#turbo-streams%3A-deliver-live-page-changes) Turbo Streams: Deliver live page changes
-----------------------------------------------------------------------------------------

Making partial page changes in response to asynchronous actions is how we make the application feel alive. While Turbo Frames give us such updates in response to direct interactions within a single frame, Turbo Streams let us change any part of the page in response to updates sent over a WebSocket connection, SSE or other transport. (Think an [imbox](http://itsnotatypo.com/) that automatically updates when a new email arrives.)

Turbo Streams introduces a `<turbo-stream>` element with eight basic actions: `append`, `prepend`, `replace`, `update`, `remove`, `before`, `after`, and `refresh`. With these actions, along with the `target` attribute specifying the ID of the element you want to operate on, you can encode all the mutations needed to refresh the page. You can even combine several stream elements in a single stream message. Simply include the HTML you’re interested in inserting or replacing in a [template tag](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/template) and Turbo does the rest:

```
<turbo-stream action="append" target="messages">
  <template>
    <div id="message_1">My new message!</div>
  </template>
</turbo-stream>
```


This stream element will take the `div` with the new message and append it to the container with the ID `messages`. It’s just as simple to replace an existing element:

```
<turbo-stream action="replace" target="message_1">
  <template>
    <div id="message_1">This changes the existing message!</div>
  </template>
</turbo-stream>
```


This is a conceptual continuation of what in the Rails world was first called [RJS](https://weblog.rubyonrails.org/2006/3/28/rails-1-1-rjs-active-record-respond_to-integration-tests-and-500-other-things/) and then called [SJR](https://signalvnoise.com/posts/3697-server-generated-javascript-responses), but realized without any need for JavaScript. The benefits remain the same:

1.  **Reuse the server-side templates**: Live page changes are generated using the same server-side templates that were used to create the first-load page.
2.  **HTML over the wire**: Since all we’re sending is HTML, you don’t need any client-side JavaScript (beyond Turbo, of course) to process the update. Yes, the HTML payload might be a tad larger than a comparable JSON, but with gzip, the difference is usually negligible, and you save all the client-side effort it takes to fetch JSON and turn it into HTML.
3.  **Simpler control flow**: It’s really clear to follow what happens when messages arrive on the WebSocket, SSE or in response to form submissions. There’s no routing, event bubbling, or other indirection required. It’s just the HTML to be changed, wrapped in a single tag that tells us how.

Now, unlike RJS and SJR, it’s not possible to call custom JavaScript functions as part of a Turbo Streams action. But this is a feature, not a bug. Those techniques can easily end up producing a tangled mess when way too much JavaScript is sent along with the response. Turbo focuses squarely on just updating the DOM, and then assumes you’ll connect any additional behavior using [Stimulus](https://stimulus.hotwired.dev/) actions and lifecycle callbacks.

[﹟](#turbo-native%3A-hybrid-apps-for-ios-%26-android) Turbo Native: Hybrid apps for iOS & Android
-------------------------------------------------------------------------------------------------

Turbo Native is ideal for building hybrid apps for iOS and Android. You can use your existing server-rendered HTML to get baseline coverage of your app’s functionality in a native wrapper. Then you can spend all the time you saved on making the few screens that really benefit from high-fidelity native controls even better.

An application like Basecamp has hundreds of screens. Rewriting every single one of those screens would be an enormous task with very little benefit. Better to reserve the native firepower for high-touch interactions that really demand the highest fidelity. Something like the “New For You” inbox in Basecamp, for example, where we use swipe controls that need to feel just right. But most pages, like the one showing a single message, wouldn’t really be any better if they were completely native.

Going hybrid doesn’t just speed up your development process, it also gives you more freedom to upgrade your app without going through the slow and onerous app store release processes. Anything that’s done in HTML can be changed in your web application, and instantly be available to all users. No waiting for Big Tech to approve your changes, no waiting for users to upgrade.

Turbo Native assumes you’re using the recommended development practices available for iOS and Android. This is not a framework that abstracts native APIs away or even tries to let your native code be shareable between platforms. The part that’s shareable is the HTML that’s rendered server-side. But the native controls are written in the recommended native APIs.

See the [Turbo Native: iOS](https://github.com/hotwired/turbo-ios) and [Turbo Native: Android](https://github.com/hotwired/turbo-android) repositories for more documentation. See the native apps for HEY on [iOS](https://apps.apple.com/us/app/hey-email/id1506603805) and [Android](https://play.google.com/store/apps/details?id=com.basecamp.hey&hl=en_US&gl=US) to get a feel for just how good you can make a hybrid app powered by Turbo.

[﹟](#integrate-with-backend-frameworks) Integrate with backend frameworks
-------------------------------------------------------------------------

You don’t need any backend framework to use Turbo. All the features are built to be used directly, without further abstractions. But if you have the opportunity to use a backend framework that’s integrated with Turbo, you’ll find life a lot simpler. [We’ve created a reference implementation for such an integration for Ruby on Rails](https://github.com/hotwired/turbo-rails).

[Next: Navigate with Turbo Drive](https://turbo.hotwired.dev/handbook/drive)



# Turbo Handbook
Turbo Streams deliver page changes as fragments of HTML wrapped in `<turbo-stream>` elements. Each stream element specifies an action together with a target ID to declare what should happen to the HTML inside it. These elements can be delivered to the browser synchronously as a classic HTTP response, or asynchronously over transports such as webSockets, SSE, etc, to bring the application alive with updates made by other users or processes.

They can be used to surgically update the DOM after a user action such as removing an element from a list without reloading the whole page, or to implement real-time capabilities such as appending a new message to a live conversation as it is sent by a remote user.

[﹟](#stream-messages-and-actions) Stream Messages and Actions
-------------------------------------------------------------

A Turbo Streams message is a fragment of HTML consisting of `<turbo-stream>` elements. The stream message below demonstrates the eight possible stream actions:

```
<turbo-stream action="append" target="messages">
  <template>
    <div id="message_1">
      This div will be appended to the element with the DOM ID "messages".
    </div>
  </template>
</turbo-stream>

<turbo-stream action="prepend" target="messages">
  <template>
    <div id="message_1">
      This div will be prepended to the element with the DOM ID "messages".
    </div>
  </template>
</turbo-stream>

<turbo-stream action="replace" target="message_1">
  <template>
    <div id="message_1">
      This div will replace the existing element with the DOM ID "message_1".
    </div>
  </template>
</turbo-stream>

<turbo-stream action="replace" method="morph" target="current_step">
  <template>
    <!-- The contents of this template will replace the element with ID "current_step" via morph. -->
    <li>New item</li>
  </template>
</turbo-stream>

<turbo-stream action="update" target="unread_count">
  <template>
    <!-- The contents of this template will replace the
    contents of the element with ID "unread_count" by
    setting innerHtml to "" and then switching in the
    template contents. Any handlers bound to the element
    "unread_count" would be retained. This is to be
    contrasted with the "replace" action above, where
    that action would necessitate the rebuilding of
    handlers. -->
    1
  </template>
</turbo-stream>

<turbo-stream action="update" method="morph" target="current_step">
  <template>
    <!-- The contents of this template will replace the children of the element with ID "current_step" via morph. -->
    <li>New item</li>
  </template>
</turbo-stream>

<turbo-stream action="remove" target="message_1">
  <!-- The element with DOM ID "message_1" will be removed.
  The contents of this stream element are ignored. -->
</turbo-stream>

<turbo-stream action="before" target="current_step">
  <template>
    <!-- The contents of this template will be added before the
    the element with ID "current_step". -->
    <li>New item</li>
  </template>
</turbo-stream>

<turbo-stream action="after" target="current_step">
  <template>
    <!-- The contents of this template will be added after the
    the element with ID "current_step". -->
    <li>New item</li>
  </template>
</turbo-stream>

<turbo-stream action="refresh" request-id="abcd-1234"></turbo-stream>
```


Note that every `<turbo-stream>` element must wrap its included HTML inside a `<template>` element.

A Turbo Stream can integrate with any element in the document that can be resolved by an [id](https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/id) attribute or [CSS selector](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Selectors) (with the exception of `<template>` element or `<iframe>` element content). It is not necessary to change targeted elements into [`<turbo-frame>` elements](https://turbo.hotwired.dev/handbook/frames). If your application utilizes `<turbo-frame>` elements for the sake of a `<turbo-stream>` element, change the `<turbo-frame>` into another [built-in element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element).

You can render any number of stream elements in a single stream message from a WebSocket, SSE or in response to a form submission.

Also, any `<turbo-stream>` element that’s inserted into the page (e.g. through full page or frame load), will be processed by Turbo and then removed from the dom. This allows stream actions to be executed automatically when a page or frame is loaded.

[﹟](#actions-with-multiple-targets) Actions With Multiple Targets
-----------------------------------------------------------------

Actions can be applied against multiple targets using the `targets` attribute with a CSS query selector, instead of the regular `target` attribute that uses a dom ID reference. Examples:

```
<turbo-stream action="remove" targets=".old_records">
  <!-- The element with the class "old_records" will be removed.
  The contents of this stream element are ignored. -->
</turbo-stream>

<turbo-stream action="after" targets="input.invalid_field">
  <template>
    <!-- The contents of this template will be added after the
    all elements that match "inputs.invalid_field". -->
    <span>Incorrect</span>
  </template>
</turbo-stream>
```


[﹟](#streaming-from-http-responses) Streaming From HTTP Responses
-----------------------------------------------------------------

Turbo knows to automatically attach `<turbo-stream>` elements when they arrive in response to `<form>` submissions that declare a [MIME type](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types) of `text/vnd.turbo-stream.html`. When submitting a `<form>` element whose [method](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/form#attr-method) attribute is set to `POST`, `PUT`, `PATCH`, or `DELETE`, Turbo injects `text/vnd.turbo-stream.html` into the set of response formats in the request’s [Accept](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept) header. When responding to requests containing that value in its [Accept](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept) header, servers can tailor their responses to deal with Turbo Streams, HTTP redirects, or other types of clients that don’t support streams (such as native applications).

In a Rails controller, this would look like:

```
def destroy
  @message = Message.find(params[:id])
  @message.destroy

  respond_to do |format|
    format.turbo_stream { render turbo_stream: turbo_stream.remove(@message) }
    format.html         { redirect_to messages_url }
  end
end
```


By default, Turbo doesn’t add the `text/vnd.turbo-stream.html` MIME type when submitting links, or forms with a method type of `GET`. To use Turbo Streams responses with `GET` requests in an application you can instruct Turbo to include the MIME type by adding a `data-turbo-stream` attribute to a link or form.

[﹟](#reusing-server-side-templates) Reusing Server-Side Templates
-----------------------------------------------------------------

The key to Turbo Streams is the ability to reuse your existing server-side templates to perform live, partial page changes. The HTML template used to render each message in a list of such on the first page load is the same template that’ll be used to add one new message to the list dynamically later. This is at the essence of the HTML-over-the-wire approach: You don’t need to serialize the new message as JSON, receive it in JavaScript, render a client-side template. It’s just the standard server-side templates reused.

Another example from how this would look in Rails:

```
<!-- app/views/messages/_message.html.erb -->
<div id="<%= dom_id message %>">
  <%= message.content %>
</div>

<!-- app/views/messages/index.html.erb -->
<h1>All the messages</h1>
<%= render partial: "messages/message", collection: @messages %>
```


```
# app/controllers/messages_controller.rb
class MessagesController < ApplicationController
  def index
    @messages = Message.all
  end

  def create
    message = Message.create!(params.require(:message).permit(:content))

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.append(:messages, partial: "messages/message",
          locals: { message: message })
      end

      format.html { redirect_to messages_url }
    end
  end
end
```


When the form to create a new message submits to the `MessagesController#create` action, the very same partial template that was used to render the list of messages in `MessagesController#index` is used to render the turbo-stream action. This will come across as a response that looks like this:

```
Content-Type: text/vnd.turbo-stream.html; charset=utf-8

<turbo-stream action="append" target="messages">
  <template>
    <div id="message_1">
      The content of the message.
    </div>
  </template>
</turbo-stream>
```


This `messages/message` template partial can then also be used to re-render the message following an edit/update operation. Or to supply new messages created by other users over a WebSocket or a SSE connection. Being able to reuse the same templates across the whole spectrum of use is incredibly powerful, and key to reducing the amount of work it takes to create these modern, fast applications.

[﹟](#progressively-enhance-when-necessary) Progressively Enhance When Necessary
-------------------------------------------------------------------------------

It’s good practice to start your interaction design without Turbo Streams. Make the entire application work as it would if Turbo Streams were not available, then layer them on as a level-up. This means you won’t come to rely on the updates for flows that need to work in native applications or elsewhere without them.

The same is especially true for WebSocket updates. On poor connections, or if there are server issues, your WebSocket may well get disconnected. If the application is designed to work without it, it’ll be more resilient.

[﹟](#but-what-about-running-javascript%3F) But What About Running JavaScript?
-----------------------------------------------------------------------------

Turbo Streams consciously restricts you to nine actions: append, prepend, (insert) before, (insert) after, replace, update, remove, morph, and refresh. If you want to trigger additional behavior when these actions are carried out, you should attach behavior using [Stimulus](https://stimulus.hotwired.dev/) controllers. This restriction allows Turbo Streams to focus on the essential task of delivering HTML over the wire, leaving additional logic to live in dedicated JavaScript files.

Embracing these constraints will keep you from turning individual responses into a jumble of behaviors that cannot be reused and which make the app hard to follow. The key benefit from Turbo Streams is the ability to reuse templates for initial rendering of a page through all subsequent updates.

[﹟](#custom-actions) Custom Actions
-----------------------------------

By default, Turbo Streams supports [eight values for its `action` attribute](about:/reference/streams#the-eight-actions). If your application needs to support other behaviors, you can override the `event.detail.render` function.

For example, if you’d like to expand upon the default actions to support `<turbo-stream>` elements with `[action="alert"]` or `[action="log"]`, you could declare a `turbo:before-stream-render` listener to provide custom behavior:

```
addEventListener("turbo:before-stream-render", ((event) => {
  const fallbackToDefaultActions = event.detail.render

  event.detail.render = function (streamElement) {
    if (streamElement.action == "alert") {
      // ...
    } else if (streamElement.action == "log") {
      // ...
    } else {
      fallbackToDefaultActions(streamElement)
    }
  }
}))
```


In addition to listening for `turbo:before-stream-render` events, applications can also declare actions as properties directly on `StreamActions`:

```
import { StreamActions } from "@hotwired/turbo"

// <turbo-stream action="log" message="Hello, world"></turbo-stream>
//
StreamActions.log = function () {
  console.log(this.getAttribute("message"))
}
```


[﹟](#integration-with-server-side-frameworks) Integration with Server-Side Frameworks
-------------------------------------------------------------------------------------

Of all the techniques that are included with Turbo, it’s with Turbo Streams you’ll see the biggest advantage from close integration with your backend framework. As part of the official Hotwire suite, we’ve created a reference implementation for what such an integration can look like in the [turbo-rails gem](https://github.com/hotwired/turbo-rails). This gem relies on the built-in support for both WebSockets and asynchronous rendering present in Rails through the Action Cable and Active Job frameworks, respectively.

Using the [Broadcastable](https://github.com/hotwired/turbo-rails/blob/main/app/models/concerns/turbo/broadcastable.rb) concern mixed into Active Record, you can trigger WebSocket updates directly from your domain model. And using the [Turbo::Streams::TagBuilder](https://github.com/hotwired/turbo-rails/blob/main/app/models/turbo/streams/tag_builder.rb), you can render `<turbo-stream>` elements in inline controller responses or dedicated templates, invoking the eight actions with associated rendering through a simple DSL.

Turbo itself is completely backend-agnostic, though. So we encourage other frameworks in other ecosystems to look at the reference implementation provided for Rails to create their own tight integration.

Turbo’s `<turbo-stream-source>` custom element connects to a stream source through its `[src]` attribute. When declared with an `ws://` or `wss://` URL, the underlying stream source will be a [WebSocket](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket) instance. Otherwise, the connection is through an [EventSource](https://developer.mozilla.org/en-US/docs/Web/API/EventSource).

When the element is connected to the document, the stream source is connected. When the element is disconnected, the stream is disconnected.

Since the document’s `<head>` is persistent across Turbo navigations, it’s important to mount the `<turbo-stream-source>` as a descendant of the document’s `<body>` element.

Typical full page navigations driven by Turbo will result in the `<body>` contents being discarded and replaced with the resulting document. It’s the server’s responsibility to ensure that the element is present on any page that requires streaming.

Alternatively, a straightforward way to integrate any backend application with Turbo Streams is to rely on [the Mercure protocol](https://mercure.rocks/). Mercure defines a convenient way for server applications to broadcast page changes to every connected clients through [Server-Sent Events (SSE)](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events). [Learn how to use Mercure with Turbo Streams](https://mercure.rocks/docs/ecosystem/hotwire).

[Next: Go Native on iOS &
Android](https://turbo.hotwired.dev/handbook/native)



# Turbo Handbook
[Turbo Drive](https://turbo.hotwired.dev/handbook/drive.html) makes navigation faster by avoiding full-page reloads. But there is a scenario where Turbo can raise the fidelity bar further: loading the current page again (page refresh).

A typical scenario for page refreshes is submitting a form and getting redirected back. In such scenarios, sensations significantly improve if only the changed contents get updated instead of replacing the `<body>` of the page. Turbo can do this on your behalf with morphing and scroll preservation.

*   [Morphing](#morphing)
*   [Scroll preservation](#scroll-preservation)
*   [Exclude sections from morphing](#exclude-sections-from-morphing)
*   [Turbo frames](#turbo-frames)
*   [Broadcasting page refreshes](#broadcasting-page-refreshes)

[﹟](#morphing) Morphing
-----------------------

You can configure how Turbo handles page refresh with a `<meta name="turbo-refresh-method">` in the page’s head.

```
<head>
  ...
  <meta name="turbo-refresh-method" content="morph">
</head>
```


The possible values are `morph` or `replace` (the default). When it is `morph,` when a page refresh happens, instead of replacing the page’s `<body>` contents, Turbo will only update the DOM elements that have changed, keeping the rest untouched. This approach delivers better sensations because it keeps the screen state.

Under the hood, Turbo uses the fantastic [idiomorph library](https://github.com/bigskysoftware/idiomorph).

You can configure how Turbo handles scrolling with a `<meta name="turbo-refresh-scroll">` in the page’s head.

```
<head>
  ...
  <meta name="turbo-refresh-scroll" content="preserve">
</head>
```


The possible values are `preserve` or `reset` (the default). When it is `preserve`, when a page refresh happens, Turbo will keep the page’s vertical and horizontal scroll.

[﹟](#exclude-sections-from-morphing) Exclude sections from morphing
-------------------------------------------------------------------

Sometimes, you want to ignore certain elements while morphing. For example, you might have a popover that you want to keep open when the page refreshes. You can flag such elements with `data-turbo-permanent`, and Turbo won’t attempt to morph them.

```
<div data-turbo-permanent>...</div>
```


[﹟](#turbo-frames) Turbo frames
-------------------------------

You can use [turbo frames](https://turbo.hotwired.dev/handbook/frames.html) to define regions in your screen that will get reloaded using morphing when a page refresh happens. To do so, you must flag those frames with `refresh="morph"`.

```
<turbo-frame id="my-frame" refresh="morph" src="/my_frame">
</turbo-frame>
```


With this mechanism, you can load additional content that didn’t arrive in the initial page load (e.g., pagination). When a page refresh happens, Turbo won’t remove the frame contents; instead, it will reload the turbo frame and render its contents with morphing.

[﹟](#broadcasting-page-refreshes) Broadcasting page refreshes
-------------------------------------------------------------

There is a new [turbo stream action](https://turbo.hotwired.dev/handbook/streams.html) called `refresh` that will trigger a page refresh:

```
<turbo-stream action="refresh"></turbo-stream>
```


Refresh behavior can be specified using the `method` and `scroll` attributes:

```
<turbo-stream action="refresh" method="morph" scroll="preserve"></turbo-stream>
```


The `method` attribute can be `morph` or `replace`, and the `scroll` attribute can be `preserve` or `reset`.

Server-side frameworks can leverage these streams to offer a simple but powerful broadcasting model: the server broadcasts a single general signal, and pages smoothly refresh with morphing.

You can see how the [`turbo-rails`](https://github.com/hotwired/turbo-rails) gem does it for Rails:

```
# In the model
class Calendar < ApplicationRecord
  broadcasts_refreshes
end

# View
turbo_stream_from @calendar
```


[Next: Decompose with Turbo Frames](https://turbo.hotwired.dev/handbook/frames)

# Turbo Handbook
Decompose with Turbo Frames
---------------------------

Turbo Frames allow predefined parts of a page to be updated on request. Any links and forms inside a frame are captured, and the frame contents automatically update after receiving a response. Regardless of whether the server provides a full document, or just a fragment containing an updated version of the requested frame, only that particular frame will be extracted from the response to replace the existing content.

Frames are created by wrapping a segment of the page in a `<turbo-frame>` element. Each element must have a unique ID, which is used to match the content being replaced when requesting new pages from the server. A single page can have multiple frames, each establishing their own context:

```
<body>
  <div id="navigation">Links targeting the entire page</div>

  <turbo-frame id="message_1">
    <h1>My message title</h1>
    <p>My message content</p>
    <a href="/messages/1/edit">Edit this message</a>
  </turbo-frame>

  <turbo-frame id="comments">
    <div id="comment_1">One comment</div>
    <div id="comment_2">Two comments</div>

    <form action="/messages/comments">...</form>
  </turbo-frame>
</body>
```


This page has two frames: One to display the message itself, with a link to edit it. One to list all the comments, with a form to add another. Each create their own context for navigation, capturing both links and submitting forms.

When the link to edit the message is clicked, the response provided by `/messages/1/edit` has its `<turbo-frame id="message_1">` segment extracted, and the content replaces the frame from where the click originated. The edit response might look like this:

```
<body>
  <h1>Editing message</h1>

  <turbo-frame id="message_1">
    <form action="/messages/1">
      <input name="message[name]" type="text" value="My message title">
      <textarea name="message[content]">My message content</textarea>
      <input type="submit">
    </form>
  </turbo-frame>
</body>
```


Notice how the `<h1>` isn’t inside the `<turbo-frame>`. This means it will remain unchanged when the form replaces the display of the message upon editing. Only content inside a matching `<turbo-frame>` is used when the frame is updated.

Thus your page can easily play dual purposes: Make edits in place within a frame or edits outside of a frame where the entire page is dedicated to the action.

Frames serve a specific purpose: to compartmentalize the content and navigation for a fragment of the document. Their presence has ramification on any `<a>` elements or `<form>` elements contained by their child content, and shouldn’t be introduced unnecessarily. Turbo Frames do not contribute support to the usage of [Turbo Stream](https://turbo.hotwired.dev/handbook/streams). If your application utilizes `<turbo-frame>` elements for the sake of a `<turbo-stream>` element, change the `<turbo-frame>` into another [built-in element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element).

[﹟](#eager-loading-frames) Eager-Loading Frames
-----------------------------------------------

Frames don’t have to be populated when the page that contains them is loaded. If a `src` attribute is present on the `turbo-frame` tag, the referenced URL will automatically be loaded as soon as the tag appears on the page:

```
<body>
  <h1>Imbox</h1>

  <div id="emails">
    ...
  </div>

  <turbo-frame id="set_aside_tray" src="/emails/set_aside">
  </turbo-frame>

  <turbo-frame id="reply_later_tray" src="/emails/reply_later">
  </turbo-frame>
</body>
```


This page lists all the emails available in your [imbox](http://itsnotatypo.com/) immediately upon loading the page, but then makes two subsequent requests to present small trays at the bottom of the page for emails that have been set aside or are waiting for a later reply. These trays are created out of separate HTTP requests made to the URLs referenced in the `src`.

In the example above, the trays start empty, but it’s also possible to populate the eager-loading frames with initial content, which is then overwritten when the content is fetched from the `src`:

```
<turbo-frame id="set_aside_tray" src="/emails/set_aside">
  <img src="/icons/spinner.gif">
</turbo-frame>
```


Upon loading the imbox page, the set-aside tray is loaded from `/emails/set_aside`, and the response must contain a corresponding `<turbo-frame id="set_aside_tray">` element as in the original example:

```
<body>
  <h1>Set Aside Emails</h1>

  <p>These are emails you've set aside</p>

  <turbo-frame id="set_aside_tray">
    <div id="emails">
      <div id="email_1">
        <a href="/emails/1">My important email</a>
      </div>
    </div>
  </turbo-frame>
</body>
```


This page now works in both its minimized form, where only the `div` with the individual emails are loaded into the tray frame on the imbox page, but also as a direct destination where a header and a description is provided. Just like in the example with the edit message form.

Note that the `<turbo-frame>` on `/emails/set_aside` does not contain a `src` attribute. That attribute is only added to the frame that needs to lazily load the content, not to the rendered frame that provides the content.

During navigation, a Frame will set `[aria-busy="true"]` on the `<turbo-frame>` element when fetching the new contents. When the navigation completes, the Frame will remove the `[aria-busy]` attribute. When navigating the `<turbo-frame>` through a `<form>` submission, Turbo will toggle the Form’s `[aria-busy="true"]` attribute in tandem with the Frame’s.

After navigation finishes, a Frame will set the `[complete]` attribute on the `<turbo-frame>` element.

[﹟](#lazy-loading-frames) Lazy-Loading Frames
---------------------------------------------

Frames that aren’t visible when the page is first loaded can be marked with `loading="lazy"` such that they don’t start loading until they become visible. This works exactly like the `loading="lazy"` attribute on `img`. It’s a great way to delay loading of frames that sit inside `summary`/`detail` pairs or modals or anything else that starts out hidden and is then revealed.

[﹟](#cache-benefits-to-loading-frames) Cache Benefits to Loading Frames
-----------------------------------------------------------------------

Turning page segments into frames can help make the page simpler to implement, but an equally important reason for doing this is to improve cache dynamics. Complex pages with many segments are hard to cache efficiently, especially if they mix content shared by many with content specialized for an individual user. The more segments, the more dependent keys required for the cache look-up, the more frequently the cache will churn.

Frames are ideal for separating segments that change on different timescales and for different audiences. Sometimes it makes sense to turn the per-user element of a page into a frame, if the bulk of the rest of the page is then easily shared across all users. Other times, it makes sense to do the opposite, where a heavily personalized page turns the one shared segment into a frame to serve it from a shared cache.

While the overhead of fetching loading frames is generally very low, you should still be judicious in just how many you load, especially if these frames would create load-in jitter on the page. Frames are, however, essentially free if the content isn’t immediately visible upon loading the page. Either because they’re hidden behind modals or below the fold.

[﹟](#targeting-navigation-into-or-out-of-a-frame) Targeting Navigation Into or Out of a Frame
---------------------------------------------------------------------------------------------

By default, navigation within a frame will target just that frame. This is true for both following links and submitting forms. But navigation can drive the entire page instead of the enclosing frame by setting the target to `_top`. Or it can drive another named frame by setting the target to the ID of that frame.

In the example with the set-aside tray, the links within the tray point to individual emails. You don’t want those links to look for frame tags that match the `set_aside_tray` ID. You want to navigate directly to that email. This is done by marking the tray frames with the `target` attribute:

```
<body>
  <h1>Imbox</h1>
  ...
  <turbo-frame id="set_aside_tray" src="/emails/set_aside" target="_top">
  </turbo-frame>
</body>

<body>
  <h1>Set Aside Emails</h1>
  ...
  <turbo-frame id="set_aside_tray" target="_top">
    ...
  </turbo-frame>
</body>
```


Sometimes you want most links to operate within the frame context, but not others. This is also true of forms. You can add the `data-turbo-frame` attribute on non-frame elements to control this:

```
<body>
  <turbo-frame id="message_1">
    ...
    <a href="/messages/1/edit">
      Edit this message (within the current frame)
    </a>

    <a href="/messages/1/permission" data-turbo-frame="_top">
      Change permissions (replace the whole page)
    </a>
  </turbo-frame>

  <form action="/messages/1/delete" data-turbo-frame="message_1">
    <a href="/messages/1/warning" data-turbo-frame="_self">
      Load warning within current frame
    </a>

    <input type="submit" value="Delete this message">
    (with a confirmation shown in a specific frame)
  </form>
</body>
```


[﹟](#promoting-a-frame-navigation-to-a-page-visit) Promoting a Frame Navigation to a Page Visit
-----------------------------------------------------------------------------------------------

Navigating Frames provides applications with an opportunity to change part of the page’s contents while preserving the rest of the document’s state (for example, its current scroll position or focused element). There are times when we want changes to a Frame to also affect the browser’s [history](https://developer.mozilla.org/en-US/docs/Web/API/History).

To promote a Frame navigation to a Visit, render the element with the `[data-turbo-action]` attribute. The attribute supports all [Visit](about:/handbook/drive#page-navigation-basics) values, and can be declared on:

*   the `<turbo-frame>` element
*   any `<a>` elements that navigate the `<turbo-frame>`
*   any `<form>` elements that navigate the `<turbo-frame>`
*   any `<input type="submit">` or `<button>` elements contained within `<form>` elements that navigate the `<turbo-frame>`

For example, consider a Frame that renders a paginated list of articles and transforms navigations into [“advance” Actions](about:/handbook/drive#application-visits):

```
<turbo-frame id="articles" data-turbo-action="advance">
  <a href="/articles?page=2" rel="next">Next page</a>
</turbo-frame>
```


Clicking the `<a rel="next">` element will set _both_ the `<turbo-frame>` element’s `[src]` attribute _and_ the browser’s path to `/articles?page=2`.

**Note:** when rendering the page after refreshing the browser, it is _the application’s_ responsibility to render the _second_ page of articles along with any other state derived from the URL path and search parameters.

[﹟](#%E2%80%9Cbreaking-out%E2%80%9D-from-a-frame) “Breaking out” from a Frame
-----------------------------------------------------------------------------

In most cases, requests that originate from a `<turbo-frame>` are expected to fetch content for that frame (or for another part of the page, depending on the use of the `target` or `data-turbo-frame` attributes). This means the response should always contain the expected `<turbo-frame>` element. If a response is missing the `<turbo-frame>` element that Turbo expects, it’s considered an error; when it happens Turbo will write an informational message into the frame, and throw an exception.

In certain, specific cases, you might want the response to a `<turbo-frame>` request to be treated as a new, full-page navigation instead, effectively “breaking out” of the frame. The classic example of this is when a lost or expired session causes an application to redirect to a login page. In this case, it’s better for Turbo to display that login page rather than treat it as an error.

The simplest way to achieve this is to specify that the login page requires a full-page reload, by including the [`turbo-visit-control`](about:/reference/attributes#meta-tags) meta tag:

```
<head>
  <meta name="turbo-visit-control" content="reload">
  ...
</head>
```


If you’re using Turbo Rails, you can use the `turbo_page_requires_reload` helper to accomplish the same thing.

Pages that specify `turbo-visit-control` `reload` will always result in a full-page navigation, even if the request originated from inside a frame.

If your application needs to handle missing frames in some other way, you can intercept the [`turbo:frame-missing`](https://turbo.hotwired.dev/reference/events) event to, for example, transform the response or perform a visit to another location.

[﹟](#anti-forgery-support-\(csrf\)) Anti-Forgery Support (CSRF)
---------------------------------------------------------------

Turbo provides [CSRF](https://en.wikipedia.org/wiki/Cross-site_request_forgery) protection by checking the DOM for the existence of a `<meta>` tag with a `name` value of either `csrf-param` or `csrf-token`. For example:

```
<meta name="csrf-token" content="[your-token]">
```


Upon form submissions, the token will be automatically added to the request’s headers as `X-CSRF-TOKEN`. Requests made with `data-turbo="false"` will skip adding the token to headers.

[﹟](#custom-rendering) Custom Rendering
---------------------------------------

Turbo’s default `<turbo-frame>` rendering process replaces the contents of the requesting `<turbo-frame>` element with the contents of a matching `<turbo-frame>` element in the response. In practice, a `<turbo-frame>` element’s contents are rendered as if they operated on by [`<turbo-stream action="update">`](about:/reference/streams#update) element. The underlying renderer extracts the contents of the `<turbo-frame>` in the response and uses them to replace the requesting `<turbo-frame>` element’s contents. The `<turbo-frame>` element itself remains unchanged, save for the [`[src]`, `[busy]`, and `[complete]` attributes that Turbo Drive manages](about:/reference/frames#html-attributes) throughout the stages of the element’s request-response lifecycle.

Applications can customize the `<turbo-frame>` rendering process by adding a `turbo:before-frame-render` event listener and overriding the `event.detail.render` property.

For example, you could merge the response `<turbo-frame>` element into the requesting `<turbo-frame>` element with [morphdom](https://github.com/patrick-steele-idem/morphdom):

```
import morphdom from "morphdom"

addEventListener("turbo:before-frame-render", (event) => {
  event.detail.render = (currentElement, newElement) => {
    morphdom(currentElement, newElement, { childrenOnly: true })
  }
})
```


Since `turbo:before-frame-render` events bubble up the document, you can override one `<turbo-frame>` element’s rendering by attaching the event listener directly to the element, or override all `<turbo-frame>` elements’ rendering by attaching the listener to the `document`.

[﹟](#pausing-rendering) Pausing Rendering
-----------------------------------------

Applications can pause rendering and make additional preparations before continuing.

Listen for the `turbo:before-frame-render` event to be notified when rendering is about to start, and pause it using `event.preventDefault()`. Once the preparation is done continue rendering by calling `event.detail.resume()`.

An example use case is adding exit animation:

```
document.addEventListener("turbo:before-frame-render", async (event) => {
  event.preventDefault()

  await animateOut()

  event.detail.resume()
})
```


[Next: Come Alive with Turbo Streams](https://turbo.hotwired.dev/handbook/streams)

# Turbo Handbook
Turbo Streams deliver page changes as fragments of HTML wrapped in `<turbo-stream>` elements. Each stream element specifies an action together with a target ID to declare what should happen to the HTML inside it. These elements can be delivered to the browser synchronously as a classic HTTP response, or asynchronously over transports such as webSockets, SSE, etc, to bring the application alive with updates made by other users or processes.

They can be used to surgically update the DOM after a user action such as removing an element from a list without reloading the whole page, or to implement real-time capabilities such as appending a new message to a live conversation as it is sent by a remote user.

[﹟](#stream-messages-and-actions) Stream Messages and Actions
-------------------------------------------------------------

A Turbo Streams message is a fragment of HTML consisting of `<turbo-stream>` elements. The stream message below demonstrates the eight possible stream actions:

```
<turbo-stream action="append" target="messages">
  <template>
    <div id="message_1">
      This div will be appended to the element with the DOM ID "messages".
    </div>
  </template>
</turbo-stream>

<turbo-stream action="prepend" target="messages">
  <template>
    <div id="message_1">
      This div will be prepended to the element with the DOM ID "messages".
    </div>
  </template>
</turbo-stream>

<turbo-stream action="replace" target="message_1">
  <template>
    <div id="message_1">
      This div will replace the existing element with the DOM ID "message_1".
    </div>
  </template>
</turbo-stream>

<turbo-stream action="replace" method="morph" target="current_step">
  <template>
    <!-- The contents of this template will replace the element with ID "current_step" via morph. -->
    <li>New item</li>
  </template>
</turbo-stream>

<turbo-stream action="update" target="unread_count">
  <template>
    <!-- The contents of this template will replace the
    contents of the element with ID "unread_count" by
    setting innerHtml to "" and then switching in the
    template contents. Any handlers bound to the element
    "unread_count" would be retained. This is to be
    contrasted with the "replace" action above, where
    that action would necessitate the rebuilding of
    handlers. -->
    1
  </template>
</turbo-stream>

<turbo-stream action="update" method="morph" target="current_step">
  <template>
    <!-- The contents of this template will replace the children of the element with ID "current_step" via morph. -->
    <li>New item</li>
  </template>
</turbo-stream>

<turbo-stream action="remove" target="message_1">
  <!-- The element with DOM ID "message_1" will be removed.
  The contents of this stream element are ignored. -->
</turbo-stream>

<turbo-stream action="before" target="current_step">
  <template>
    <!-- The contents of this template will be added before the
    the element with ID "current_step". -->
    <li>New item</li>
  </template>
</turbo-stream>

<turbo-stream action="after" target="current_step">
  <template>
    <!-- The contents of this template will be added after the
    the element with ID "current_step". -->
    <li>New item</li>
  </template>
</turbo-stream>

<turbo-stream action="refresh" request-id="abcd-1234"></turbo-stream>
```


Note that every `<turbo-stream>` element must wrap its included HTML inside a `<template>` element.

A Turbo Stream can integrate with any element in the document that can be resolved by an [id](https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/id) attribute or [CSS selector](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Selectors) (with the exception of `<template>` element or `<iframe>` element content). It is not necessary to change targeted elements into [`<turbo-frame>` elements](https://turbo.hotwired.dev/handbook/frames). If your application utilizes `<turbo-frame>` elements for the sake of a `<turbo-stream>` element, change the `<turbo-frame>` into another [built-in element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element).

You can render any number of stream elements in a single stream message from a WebSocket, SSE or in response to a form submission.

Also, any `<turbo-stream>` element that’s inserted into the page (e.g. through full page or frame load), will be processed by Turbo and then removed from the dom. This allows stream actions to be executed automatically when a page or frame is loaded.

[﹟](#actions-with-multiple-targets) Actions With Multiple Targets
-----------------------------------------------------------------

Actions can be applied against multiple targets using the `targets` attribute with a CSS query selector, instead of the regular `target` attribute that uses a dom ID reference. Examples:

```
<turbo-stream action="remove" targets=".old_records">
  <!-- The element with the class "old_records" will be removed.
  The contents of this stream element are ignored. -->
</turbo-stream>

<turbo-stream action="after" targets="input.invalid_field">
  <template>
    <!-- The contents of this template will be added after the
    all elements that match "inputs.invalid_field". -->
    <span>Incorrect</span>
  </template>
</turbo-stream>
```


[﹟](#streaming-from-http-responses) Streaming From HTTP Responses
-----------------------------------------------------------------

Turbo knows to automatically attach `<turbo-stream>` elements when they arrive in response to `<form>` submissions that declare a [MIME type](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types) of `text/vnd.turbo-stream.html`. When submitting a `<form>` element whose [method](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/form#attr-method) attribute is set to `POST`, `PUT`, `PATCH`, or `DELETE`, Turbo injects `text/vnd.turbo-stream.html` into the set of response formats in the request’s [Accept](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept) header. When responding to requests containing that value in its [Accept](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept) header, servers can tailor their responses to deal with Turbo Streams, HTTP redirects, or other types of clients that don’t support streams (such as native applications).

In a Rails controller, this would look like:

```
def destroy
  @message = Message.find(params[:id])
  @message.destroy

  respond_to do |format|
    format.turbo_stream { render turbo_stream: turbo_stream.remove(@message) }
    format.html         { redirect_to messages_url }
  end
end
```


By default, Turbo doesn’t add the `text/vnd.turbo-stream.html` MIME type when submitting links, or forms with a method type of `GET`. To use Turbo Streams responses with `GET` requests in an application you can instruct Turbo to include the MIME type by adding a `data-turbo-stream` attribute to a link or form.

[﹟](#reusing-server-side-templates) Reusing Server-Side Templates
-----------------------------------------------------------------

The key to Turbo Streams is the ability to reuse your existing server-side templates to perform live, partial page changes. The HTML template used to render each message in a list of such on the first page load is the same template that’ll be used to add one new message to the list dynamically later. This is at the essence of the HTML-over-the-wire approach: You don’t need to serialize the new message as JSON, receive it in JavaScript, render a client-side template. It’s just the standard server-side templates reused.

Another example from how this would look in Rails:

```
<!-- app/views/messages/_message.html.erb -->
<div id="<%= dom_id message %>">
  <%= message.content %>
</div>

<!-- app/views/messages/index.html.erb -->
<h1>All the messages</h1>
<%= render partial: "messages/message", collection: @messages %>
```


```
# app/controllers/messages_controller.rb
class MessagesController < ApplicationController
  def index
    @messages = Message.all
  end

  def create
    message = Message.create!(params.require(:message).permit(:content))

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.append(:messages, partial: "messages/message",
          locals: { message: message })
      end

      format.html { redirect_to messages_url }
    end
  end
end
```


When the form to create a new message submits to the `MessagesController#create` action, the very same partial template that was used to render the list of messages in `MessagesController#index` is used to render the turbo-stream action. This will come across as a response that looks like this:

```
Content-Type: text/vnd.turbo-stream.html; charset=utf-8

<turbo-stream action="append" target="messages">
  <template>
    <div id="message_1">
      The content of the message.
    </div>
  </template>
</turbo-stream>
```


This `messages/message` template partial can then also be used to re-render the message following an edit/update operation. Or to supply new messages created by other users over a WebSocket or a SSE connection. Being able to reuse the same templates across the whole spectrum of use is incredibly powerful, and key to reducing the amount of work it takes to create these modern, fast applications.

[﹟](#progressively-enhance-when-necessary) Progressively Enhance When Necessary
-------------------------------------------------------------------------------

It’s good practice to start your interaction design without Turbo Streams. Make the entire application work as it would if Turbo Streams were not available, then layer them on as a level-up. This means you won’t come to rely on the updates for flows that need to work in native applications or elsewhere without them.

The same is especially true for WebSocket updates. On poor connections, or if there are server issues, your WebSocket may well get disconnected. If the application is designed to work without it, it’ll be more resilient.

[﹟](#but-what-about-running-javascript%3F) But What About Running JavaScript?
-----------------------------------------------------------------------------

Turbo Streams consciously restricts you to nine actions: append, prepend, (insert) before, (insert) after, replace, update, remove, morph, and refresh. If you want to trigger additional behavior when these actions are carried out, you should attach behavior using [Stimulus](https://stimulus.hotwired.dev/) controllers. This restriction allows Turbo Streams to focus on the essential task of delivering HTML over the wire, leaving additional logic to live in dedicated JavaScript files.

Embracing these constraints will keep you from turning individual responses into a jumble of behaviors that cannot be reused and which make the app hard to follow. The key benefit from Turbo Streams is the ability to reuse templates for initial rendering of a page through all subsequent updates.

[﹟](#custom-actions) Custom Actions
-----------------------------------

By default, Turbo Streams supports [eight values for its `action` attribute](about:/reference/streams#the-eight-actions). If your application needs to support other behaviors, you can override the `event.detail.render` function.

For example, if you’d like to expand upon the default actions to support `<turbo-stream>` elements with `[action="alert"]` or `[action="log"]`, you could declare a `turbo:before-stream-render` listener to provide custom behavior:

```
addEventListener("turbo:before-stream-render", ((event) => {
  const fallbackToDefaultActions = event.detail.render

  event.detail.render = function (streamElement) {
    if (streamElement.action == "alert") {
      // ...
    } else if (streamElement.action == "log") {
      // ...
    } else {
      fallbackToDefaultActions(streamElement)
    }
  }
}))
```


In addition to listening for `turbo:before-stream-render` events, applications can also declare actions as properties directly on `StreamActions`:

```
import { StreamActions } from "@hotwired/turbo"

// <turbo-stream action="log" message="Hello, world"></turbo-stream>
//
StreamActions.log = function () {
  console.log(this.getAttribute("message"))
}
```


[﹟](#integration-with-server-side-frameworks) Integration with Server-Side Frameworks
-------------------------------------------------------------------------------------

Of all the techniques that are included with Turbo, it’s with Turbo Streams you’ll see the biggest advantage from close integration with your backend framework. As part of the official Hotwire suite, we’ve created a reference implementation for what such an integration can look like in the [turbo-rails gem](https://github.com/hotwired/turbo-rails). This gem relies on the built-in support for both WebSockets and asynchronous rendering present in Rails through the Action Cable and Active Job frameworks, respectively.

Using the [Broadcastable](https://github.com/hotwired/turbo-rails/blob/main/app/models/concerns/turbo/broadcastable.rb) concern mixed into Active Record, you can trigger WebSocket updates directly from your domain model. And using the [Turbo::Streams::TagBuilder](https://github.com/hotwired/turbo-rails/blob/main/app/models/turbo/streams/tag_builder.rb), you can render `<turbo-stream>` elements in inline controller responses or dedicated templates, invoking the eight actions with associated rendering through a simple DSL.

Turbo itself is completely backend-agnostic, though. So we encourage other frameworks in other ecosystems to look at the reference implementation provided for Rails to create their own tight integration.

Turbo’s `<turbo-stream-source>` custom element connects to a stream source through its `[src]` attribute. When declared with an `ws://` or `wss://` URL, the underlying stream source will be a [WebSocket](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket) instance. Otherwise, the connection is through an [EventSource](https://developer.mozilla.org/en-US/docs/Web/API/EventSource).

When the element is connected to the document, the stream source is connected. When the element is disconnected, the stream is disconnected.

Since the document’s `<head>` is persistent across Turbo navigations, it’s important to mount the `<turbo-stream-source>` as a descendant of the document’s `<body>` element.

Typical full page navigations driven by Turbo will result in the `<body>` contents being discarded and replaced with the resulting document. It’s the server’s responsibility to ensure that the element is present on any page that requires streaming.

Alternatively, a straightforward way to integrate any backend application with Turbo Streams is to rely on [the Mercure protocol](https://mercure.rocks/). Mercure defines a convenient way for server applications to broadcast page changes to every connected clients through [Server-Sent Events (SSE)](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events). [Learn how to use Mercure with Turbo Streams](https://mercure.rocks/docs/ecosystem/hotwire).

[Next: Go Native on iOS & Android](https://turbo.hotwired.dev/handbook/native)


```
---
Source: https://raw.githubusercontent.com/hotwired/turbo-rails/refs/heads/main/app/helpers/turbo/frames_helper.rb
---

module Turbo::FramesHelper
  # Returns a frame tag that can either be used simply to encapsulate frame content or as a lazy-loading container that starts empty but
  # fetches the URL supplied in the +src+ attribute.
  #
  # ==== Examples
  #
  #   <%= turbo_frame_tag "tray", src: tray_path(tray) %>
  #   # => <turbo-frame id="tray" src="http://example.com/trays/1"></turbo-frame>
  #
  #   <%= turbo_frame_tag tray, src: tray_path(tray) %>
  #   # => <turbo-frame id="tray_1" src="http://example.com/trays/1"></turbo-frame>
  #
  #   <%= turbo_frame_tag "tray", src: tray_path(tray), target: "_top" %>
  #   # => <turbo-frame id="tray" target="_top" src="http://example.com/trays/1"></turbo-frame>
  #
  #   <%= turbo_frame_tag "tray", target: "other_tray" %>
  #   # => <turbo-frame id="tray" target="other_tray"></turbo-frame>
  #
  #   <%= turbo_frame_tag "tray", src: tray_path(tray), loading: "lazy" %>
  #   # => <turbo-frame id="tray" src="http://example.com/trays/1" loading="lazy"></turbo-frame>
  #
  #   <%= turbo_frame_tag "tray" do %>
  #     <div>My tray frame!</div>
  #   <% end %>
  #   # => <turbo-frame id="tray"><div>My tray frame!</div></turbo-frame>
  #
  #   <%= turbo_frame_tag [user_id, "tray"], src: tray_path(tray) %>
  #   # => <turbo-frame id="1_tray" src="http://example.com/trays/1"></turbo-frame>
  #
  # The +turbo_frame_tag+ helper will convert the arguments it receives to their
  # +dom_id+ if applicable to easily generate unique ids for Turbo Frames:
  #
  #   <%= turbo_frame_tag(Article.find(1)) %>
  #   # => <turbo-frame id="article_1"></turbo-frame>
  #
  #   <%= turbo_frame_tag(Article) %>
  #   # => <turbo-frame id="new_article"></turbo-frame>
  #
  #   <%= turbo_frame_tag(Article.find(1), "comments") %>
  #   # => <turbo-frame id="comments_article_1"></turbo-frame>
  def turbo_frame_tag(*ids, src: nil, target: nil, **attributes, &block)
    id = ids.first.respond_to?(:to_key) || ids.first.is_a?(Class) ? ActionView::RecordIdentifier.dom_id(*ids) : ids.join('_')
    src = url_for(src) if src.present?

    tag.turbo_frame(**attributes.merge(id: id, src: src, target: target).compact, &block)
  end
end


---
Source: https://raw.githubusercontent.com/hotwired/turbo-rails/refs/heads/main/app/helpers/turbo/streams_helper.rb
---

module Turbo::StreamsHelper
  # Returns a new <tt>Turbo::Streams::TagBuilder</tt> object that accepts stream actions and renders them as
  # the template tags needed to send across the wire. This object is automatically yielded to turbo_stream.erb templates.
  #
  # When responding to HTTP requests, controllers can declare `turbo_stream` format response templates in that same
  # style as `html` and `json` response formats. For example, consider a `MessagesController` that responds to both
  # `text/html` and `text/vnd.turbo-stream.html` requests along with a `.turbo_stream.erb` action template:
  #
  #   def create
  #     @message = Message.create!(params.require(:message).permit(:content))
  #     respond_to do |format|
  #       format.turbo_stream
  #       format.html { redirect_to messages_url }
  #     end
  #   end
  #
  #   <%# app/views/messages/create.turbo_stream.erb %>
  #   <%= turbo_stream.append "messages", @message %>
  #
  #   <%= turbo_stream.replace "new_message" do %>
  #     <%= render partial: "new_message", locals: { room: @room } %>
  #   <% end %>
  #
  # When a `app/views/messages/create.turbo_stream.erb` template exists, the
  # `MessagesController#create` will respond to `text/vnd.turbo-stream.html`
  # requests by rendering the `messages/create.turbo_stream.erb` view template and transmitting the response
  def turbo_stream
    Turbo::Streams::TagBuilder.new(self)
  end

  # Used in the view to create a subscription to a stream identified by the <tt>streamables</tt> running over the
  # <tt>Turbo::StreamsChannel</tt>. The stream name being generated is safe to embed in the HTML sent to a user without
  # fear of tampering, as it is signed using <tt>Turbo.signed_stream_verifier</tt>. Example:
  #
  #   # app/views/entries/index.html.erb
  #   <%= turbo_stream_from Current.account, :entries %>
  #   <div id="entries">New entries will be appended to this target</div>
  #
  # The example above will process all turbo streams sent to a stream name like <tt>account:5:entries</tt>
  # (when Current.account.id = 5). Updates to this stream can be sent like
  # <tt>entry.broadcast_append_to entry.account, :entries, target: "entries"</tt>.
  #
  # Custom channel class name can be passed using <tt>:channel</tt> option (either as a String
  # or a class name):
  #
  #   <%= turbo_stream_from "room", channel: RoomChannel %>
  #
  # It is also possible to pass additional parameters to the channel by passing them through `data` attributes:
  #
  #   <%= turbo_stream_from "room", channel: RoomChannel, data: {room_name: "room #1"} %>
  #
  # Raises an +ArgumentError+ if all streamables are blank
  #
  #   <%= turbo_stream_from("") %> # => ArgumentError: streamables can't be blank
  #   <%= turbo_stream_from("", nil) %> # => ArgumentError: streamables can't be blank
  def turbo_stream_from(*streamables, **attributes)
    raise ArgumentError, "streamables can't be blank" unless streamables.any?(&:present?)
    attributes[:channel] = attributes[:channel]&.to_s || "Turbo::StreamsChannel"
    attributes[:"signed-stream-name"] = Turbo::StreamsChannel.signed_stream_name(streamables)

    tag.turbo_cable_stream_source(**attributes)
  end
end


---
Source: https://raw.githubusercontent.com/hotwired/turbo-rails/refs/heads/main/app/models/turbo/streams/tag_builder.rb
---

# This tag builder is used both for inline controller turbo actions (see <tt>Turbo::Streams::TurboStreamsTagBuilder</tt>) and for
# turbo stream templates. This object plays together with any normal Ruby you'd run in an ERB template, so you can iterate, like:
#
#   <% # app/views/postings/destroy.turbo_stream.erb %>
#   <% @postings.each do |posting| %>
#     <%= turbo_stream.remove posting %>
#   <% end %>
#
# Or string several separate updates together:
#
#   <% # app/views/entries/_entry.turbo_stream.erb %>
#   <%= turbo_stream.remove entry %>
#
#   <%= turbo_stream.append "entries" do %>
#     <% # format is automatically switched, such that _entry.html.erb partial is rendered, not _entry.turbo_stream.erb %>
#     <%= render partial: "entries/entry", locals: { entry: entry } %>
#   <% end %>
#
# Or you can render the HTML that should be part of the update inline:
#
#   <% # app/views/topics/merges/_merge.turbo_stream.erb %>
#   <%= turbo_stream.append dom_id(topic_merge) do %>
#     <%= link_to topic_merge.topic.name, topic_path(topic_merge.topic) %>
#   <% end %>
#
# To integrate with custom actions, extend this class in response to the :turbo_streams_tag_builder load hook:
#
#   ActiveSupport.on_load :turbo_streams_tag_builder do
#     def highlight(target)
#       action :highlight, target
#     end
#
#     def highlight_all(targets)
#       action_all :highlight, targets
#     end
#   end
#
#   turbo_stream.highlight "my-element"
#   # => <turbo-stream action="highlight" target="my-element"><template></template></turbo-stream>
#
#   turbo_stream.highlight_all ".my-selector"
#   # => <turbo-stream action="highlight" targets=".my-selector"><template></template></turbo-stream>
class Turbo::Streams::TagBuilder
  include Turbo::Streams::ActionHelper

  def initialize(view_context)
    @view_context = view_context
    @view_context.formats |= [:html]
  end

  # Removes the <tt>target</tt> from the dom. The target can either be a dom id string or an object that responds to
  # <tt>to_key</tt>, which is then called and passed through <tt>ActionView::RecordIdentifier.dom_id</tt> (all Active Records
  # do). Examples:
  #
  #   <%= turbo_stream.remove "clearance_5" %>
  #   <%= turbo_stream.remove clearance %>
  def remove(target)
    action :remove, target, allow_inferred_rendering: false
  end

  # Removes the <tt>targets</tt> from the dom. The targets can either be a CSS selector string or an object that responds to
  # <tt>to_key</tt>, which is then called and passed through <tt>ActionView::RecordIdentifier.dom_id</tt> (all Active Records
  # do). Examples:
  #
  #   <%= turbo_stream.remove_all ".clearance_item" %>
  #   <%= turbo_stream.remove_all clearance %>
  def remove_all(targets)
    action_all :remove, targets, allow_inferred_rendering: false
  end

  # Replace the <tt>target</tt> in the dom with either the <tt>content</tt> passed in, a rendering result determined
  # by the <tt>rendering</tt> keyword arguments, the content in the block, or the rendering of the target as a record. Examples:
  #
  #   <%= turbo_stream.replace "clearance_5", "<div id='clearance_5'>Replace the dom target identified by clearance_5</div>" %>
  #   <%= turbo_stream.replace clearance %>
  #   <%= turbo_stream.replace clearance, partial: "clearances/clearance", locals: { title: "Hello" } %>
  #   <%= turbo_stream.replace "clearance_5" do %>
  #     <div id='clearance_5'>Replace the dom target identified by clearance_5</div>
  #   <% end %>
  #   <%= turbo_stream.replace clearance, "<div>Morph the dom target</div>", method: :morph %>
  def replace(target, content = nil, method: nil, **rendering, &block)
    action :replace, target, content, method: method, **rendering, &block
  end

  # Replace the <tt>targets</tt> in the dom with either the <tt>content</tt> passed in, a rendering result determined
  # by the <tt>rendering</tt> keyword arguments, the content in the block, or the rendering of the target as a record. Examples:
  #
  #   <%= turbo_stream.replace_all ".clearance_item", "<div class='clearance_item'>Replace the dom target identified by the class clearance_item</div>" %>
  #   <%= turbo_stream.replace_all clearance %>
  #   <%= turbo_stream.replace_all clearance, partial: "clearances/clearance", locals: { title: "Hello" } %>
  #   <%= turbo_stream.replace_all ".clearance_item" do %>
  #     <div class='.clearance_item'>Replace the dom target identified by the class clearance_item</div>
  #   <% end %>
  #   <%= turbo_stream.replace_all clearance, "<div>Morph the dom target</div>", method: :morph %>
  def replace_all(targets, content = nil, method: nil, **rendering, &block)
    action_all :replace, targets, content, method: method, **rendering, &block
  end

  # Insert the <tt>content</tt> passed in, a rendering result determined by the <tt>rendering</tt> keyword arguments,
  # the content in the block, or the rendering of the target as a record before the <tt>target</tt> in the dom. Examples:
  #
  #   <%= turbo_stream.before "clearance_5", "<div id='clearance_4'>Insert before the dom target identified by clearance_5</div>" %>
  #   <%= turbo_stream.before clearance %>
  #   <%= turbo_stream.before clearance, partial: "clearances/clearance", locals: { title: "Hello" } %>
  #   <%= turbo_stream.before "clearance_5" do %>
  #     <div id='clearance_4'>Insert before the dom target identified by clearance_5</div>
  #   <% end %>
  def before(target, content = nil, **rendering, &block)
    action :before, target, content, **rendering, &block
  end

  # Insert the <tt>content</tt> passed in, a rendering result determined by the <tt>rendering</tt> keyword arguments,
  # the content in the block, or the rendering of the target as a record before the <tt>targets</tt> in the dom. Examples:
  #
  #   <%= turbo_stream.before_all ".clearance_item", "<div class='clearance_item'>Insert before the dom target identified by the class clearance_item</div>" %>
  #   <%= turbo_stream.before_all clearance %>
  #   <%= turbo_stream.before_all clearance, partial: "clearances/clearance", locals: { title: "Hello" } %>
  #   <%= turbo_stream.before_all ".clearance_item" do %>
  #     <div class='clearance_item'>Insert before the dom target identified by clearance_item</div>
  #   <% end %>
  def before_all(targets, content = nil, **rendering, &block)
    action_all :before, targets, content, **rendering, &block
  end

  # Insert the <tt>content</tt> passed in, a rendering result determined by the <tt>rendering</tt> keyword arguments,
  # the content in the block, or the rendering of the target as a record after the <tt>target</tt> in the dom. Examples:
  #
  #   <%= turbo_stream.after "clearance_5", "<div id='clearance_6'>Insert after the dom target identified by clearance_5</div>" %>
  #   <%= turbo_stream.after clearance %>
  #   <%= turbo_stream.after clearance, partial: "clearances/clearance", locals: { title: "Hello" } %>
  #   <%= turbo_stream.after "clearance_5" do %>
  #     <div id='clearance_6'>Insert after the dom target identified by clearance_5</div>
  #   <% end %>
  def after(target, content = nil, **rendering, &block)
    action :after, target, content, **rendering, &block
  end

  # Insert the <tt>content</tt> passed in, a rendering result determined by the <tt>rendering</tt> keyword arguments,
  # the content in the block, or the rendering of the target as a record after the <tt>targets</tt> in the dom. Examples:
  #
  #   <%= turbo_stream.after_all ".clearance_item", "<div class='clearance_item'>Insert after the dom target identified by the class clearance_item</div>" %>
  #   <%= turbo_stream.after_all clearance %>
  #   <%= turbo_stream.after_all clearance, partial: "clearances/clearance", locals: { title: "Hello" } %>
  #   <%= turbo_stream.after_all "clearance_item" do %>
  #     <div class='clearance_item'>Insert after the dom target identified by the class clearance_item</div>
  #   <% end %>
  def after_all(targets, content = nil, **rendering, &block)
    action_all :after, targets, content, **rendering, &block
  end

  # Update the <tt>target</tt> in the dom with either the <tt>content</tt> passed in or a rendering result determined
  # by the <tt>rendering</tt> keyword arguments, the content in the block, or the rendering of the target as a record. Examples:
  #
  #   <%= turbo_stream.update "clearance_5", "Update the content of the dom target identified by clearance_5" %>
  #   <%= turbo_stream.update clearance %>
  #   <%= turbo_stream.update clearance, partial: "clearances/unique_clearance", locals: { title: "Hello" } %>
  #   <%= turbo_stream.update "clearance_5" do %>
  #     Update the content of the dom target identified by clearance_5
  #   <% end %>
  #   <%= turbo_stream.update clearance, "<div>Morph the dom target</div>", method: :morph %>
  def update(target, content = nil, method: nil, **rendering, &block)
    action :update, target, content, method: method, **rendering, &block
  end

  # Update the <tt>targets</tt> in the dom with either the <tt>content</tt> passed in or a rendering result determined
  # by the <tt>rendering</tt> keyword arguments, the content in the block, or the rendering of the targets as a record. Examples:
  #
  #   <%= turbo_stream.update_all "clearance_item", "Update the content of the dom target identified by the class clearance_item" %>
  #   <%= turbo_stream.update_all clearance %>
  #   <%= turbo_stream.update_all clearance, partial: "clearances/new_clearance", locals: { title: "Hello" } %>
  #   <%= turbo_stream.update_all "clearance_item" do %>
  #     Update the content of the dom target identified by the class clearance_item
  #   <% end %>
  #   <%= turbo_stream.update_all clearance, "<div>Morph the dom target</div>", method: :morph %>
  def update_all(targets, content = nil, method: nil, **rendering, &block)
    action_all :update, targets, content, method: method, **rendering, &block
  end

  # Append to the target in the dom identified with <tt>target</tt> either the <tt>content</tt> passed in or a
  # rendering result determined by the <tt>rendering</tt> keyword arguments, the content in the block,
  # or the rendering of the content as a record. Examples:
  #
  #   <%= turbo_stream.append "clearances", "<div id='clearance_5'>Append this to .clearances</div>" %>
  #   <%= turbo_stream.append "clearances", clearance %>
  #   <%= turbo_stream.append "clearances", partial: "clearances/unique_clearance", locals: { clearance: clearance } %>
  #   <%= turbo_stream.append "clearances" do %>
  #     <div id='clearance_5'>Append this to .clearances</div>
  #   <% end %>
  def append(target, content = nil, **rendering, &block)
    action :append, target, content, **rendering, &block
  end

  # Append to the targets in the dom identified with <tt>targets</tt> either the <tt>content</tt> passed in or a
  # rendering result determined by the <tt>rendering</tt> keyword arguments, the content in the block,
  # or the rendering of the content as a record. Examples:
  #
  #   <%= turbo_stream.append_all ".clearances", "<div class='clearance_item'>Append this to .clearance_group</div>" %>
  #   <%= turbo_stream.append_all ".clearances", clearance %>
  #   <%= turbo_stream.append_all ".clearances", partial: "clearances/new_clearance", locals: { clearance: clearance } %>
  #   <%= turbo_stream.append_all ".clearances" do %>
  #     <div id='clearance_item'>Append this to .clearances</div>
  #   <% end %>
  def append_all(targets, content = nil, **rendering, &block)
    action_all :append, targets, content, **rendering, &block
  end

  # Prepend to the target in the dom identified with <tt>target</tt> either the <tt>content</tt> passed in or a
  # rendering result determined by the <tt>rendering</tt> keyword arguments or the content in the block,
  # or the rendering of the content as a record. Examples:
  #
  #   <%= turbo_stream.prepend "clearances", "<div id='clearance_5'>Prepend this to .clearances</div>" %>
  #   <%= turbo_stream.prepend "clearances", clearance %>
  #   <%= turbo_stream.prepend "clearances", partial: "clearances/unique_clearance", locals: { clearance: clearance } %>
  #   <%= turbo_stream.prepend "clearances" do %>
  #     <div id='clearance_5'>Prepend this to .clearances</div>
  #   <% end %>
  def prepend(target, content = nil, **rendering, &block)
    action :prepend, target, content, **rendering, &block
  end

  # Prepend to the targets in the dom identified with <tt>targets</tt> either the <tt>content</tt> passed in or a
  # rendering result determined by the <tt>rendering</tt> keyword arguments or the content in the block,
  # or the rendering of the content as a record. Examples:
  #
  #   <%= turbo_stream.prepend_all ".clearances", "<div class='clearance_item'>Prepend this to .clearances</div>" %>
  #   <%= turbo_stream.prepend_all ".clearances", clearance %>
  #   <%= turbo_stream.prepend_all ".clearances", partial: "clearances/new_clearance", locals: { clearance: clearance } %>
  #   <%= turbo_stream.prepend_all ".clearances" do %>
  #     <div class='clearance_item'>Prepend this to .clearances</div>
  #   <% end %>
  def prepend_all(targets, content = nil, **rendering, &block)
    action_all :prepend, targets, content, **rendering, &block
  end

  # Creates a `turbo-stream` tag with an `[action="refresh"`] attribute and a
  # `[request-id]` attribute that defaults to `Turbo.current_request_id`:
  #
  #   turbo_stream.refresh
  #   # => <turbo-stream action="refresh" request-id="ef083d55-7516-41b1-ad28-16f553399c6a"></turbo-stream>
  #
  #   turbo_stream.refresh request_id: "abc123"
  #   # => <turbo-stream action="refresh" request-id="abc123"></turbo-stream>
  def refresh(...)
    turbo_stream_refresh_tag(...)
  end

  # Send an action of the type <tt>name</tt> to <tt>target</tt>. Options described in the concrete methods.
  def action(name, target, content = nil, method: nil, allow_inferred_rendering: true, **rendering, &block)
    template = render_template(target, content, allow_inferred_rendering: allow_inferred_rendering, **rendering, &block)

    turbo_stream_action_tag name, target: target, template: template, method: method
  end

  # Send an action of the type <tt>name</tt> to <tt>targets</tt>. Options described in the concrete methods.
  def action_all(name, targets, content = nil, method: nil, allow_inferred_rendering: true, **rendering, &block)
    template = render_template(targets, content, allow_inferred_rendering: allow_inferred_rendering, **rendering, &block)

    turbo_stream_action_tag name, targets: targets, template: template, method: method
  end

  private
    def render_template(target, content = nil, allow_inferred_rendering: true, **rendering, &block)
      case
      when target.respond_to?(:render_in) && content.nil?
        target.render_in(@view_context, &block)
      when content.respond_to?(:render_in)
        content.render_in(@view_context, &block)
      when content
        allow_inferred_rendering ? (render_record(content) || content) : content
      when block_given? && (rendering.key?(:partial) || rendering.key?(:layout))
        @view_context.render(formats: [ :html ], layout: rendering[:partial], **rendering, &block)
      when block_given?
        @view_context.capture(&block)
      when rendering.any?
        @view_context.render(formats: [ :html ], **rendering)
      else
        render_record(target) if allow_inferred_rendering
      end
    end

    def render_record(possible_record)
      if possible_record.respond_to?(:to_partial_path)
        record = possible_record
        @view_context.render(partial: record, formats: :html)
      end
    end

  ActiveSupport.run_load_hooks :turbo_streams_tag_builder, self
end


---
Source: https://raw.githubusercontent.com/hotwired/turbo-rails/refs/heads/main/app/models/concerns/turbo/broadcastable.rb
---

# Turbo streams can be broadcasted directly from models that include this module (this is automatically done for Active Records if ActiveJob is loaded).
# This makes it convenient to execute both synchronous and asynchronous updates, and render directly from callbacks in models
# or from controllers or jobs that act on those models. Here's an example:
#
#   class Clearance < ApplicationRecord
#     belongs_to :petitioner, class_name: "Contact"
#     belongs_to :examiner,   class_name: "User"
#
#     after_create_commit :broadcast_later
#
#     private
#       def broadcast_later
#         broadcast_prepend_later_to examiner.identity, :clearances
#       end
#   end
#
# This is an example from {HEY}[https://hey.com], and the clearance is the model that drives
# {the screener}[https://hey.com/features/the-screener/], which gives users the power to deny first-time senders (petitioners)
# access to their attention (as the examiner). When a new clearance is created upon receipt of an email from a first-time
# sender, that'll trigger the call to broadcast_later, which in turn invokes <tt>broadcast_prepend_later_to</tt>.
#
# That method enqueues a <tt>Turbo::Streams::ActionBroadcastJob</tt> for the prepend, which will render the partial for clearance
# (it knows which by calling Clearance#to_partial_path, which in this case returns <tt>clearances/_clearance.html.erb</tt>),
# send that to all users that have subscribed to updates (using <tt>turbo_stream_from(examiner.identity, :clearances)</tt> in a view)
# using the <tt>Turbo::StreamsChannel</tt> under the stream name derived from <tt>[ examiner.identity, :clearances ]</tt>,
# and finally prepend the result of that partial rendering to the target identified with the dom id "clearances"
# (which is derived by default from the plural model name of the model, but can be overwritten).
#
# You can also choose to render html instead of a partial inside of a broadcast
# you do this by passing the +html:+ option to any broadcast method that accepts the **rendering argument. Example:
#
#   class Message < ApplicationRecord
#     belongs_to :user
#
#     after_create_commit :update_message_count
#
#     private
#       def update_message_count
#         broadcast_update_to(user, :messages, target: "message-count", html: "<p> #{user.messages.count} </p>")
#       end
#   end
#
# If you want to render a template instead of a partial, e.g. ('messages/index' or 'messages/show'), you can use the +template:+ option.
# Again, only to any broadcast method that accepts the +**rendering+ argument. Example:
#
#   class Message < ApplicationRecord
#     belongs_to :user
#
#     after_create_commit :update_message
#
#     private
#       def update_message
#         broadcast_replace_to(user, :message, target: "message", template: "messages/show", locals: { message: self })
#       end
#   end
#
# If you want to render a renderable object you can use the +renderable:+ option.
#
#   class Message < ApplicationRecord
#     belongs_to :user
#
#     after_create_commit :update_message
#
#     private
#       def update_message
#         broadcast_replace_to(user, :message, target: "message", renderable: MessageComponent.new)
#       end
#   end
#
# There are seven basic actions you can broadcast: <tt>after</tt>, <tt>append</tt>, <tt>before</tt>,
# <tt>prepend</tt>, <tt>remove</tt>, <tt>replace</tt>, and
# <tt>update</tt>. As a rule, you should use the <tt>_later</tt> versions of everything except for remove when broadcasting
# within a real-time path, like a controller or model, since all those updates require a rendering step, which can slow down
# execution. You don't need to do this for remove, since only the dom id for the model is used.
#
# In addition to the seven basic actions, you can also use <tt>broadcast_render</tt>,
# <tt>broadcast_render_to</tt> <tt>broadcast_render_later</tt>, and <tt>broadcast_render_later_to</tt>
# to render a turbo stream template with multiple actions.
#
# == Page refreshes
#
# You can broadcast "page refresh" stream actions. This will make subscribed clients reload the
# page. For pages that configure morphing and scroll preservation, this will translate into smooth
# updates when it only updates the content that changed.
#
# This approach is an alternative to fine-grained stream actions targeting specific DOM elements. It
# offers good fidelity with a much simpler programming model. As a tradeoff, the fidelity you can reach
# is often not as high as with targeted stream actions since it renders the entire page again.
#
# The +broadcasts_refreshes+ class method configures the model to broadcast a "page refresh" on creates,
# updates, and destroys to a stream name derived at runtime by the <tt>stream</tt> symbol invocation. Examples
#
#   class Board < ApplicationRecord
#     broadcasts_refreshes
#   end
#
# In this example, when a board is created, updated, or destroyed, a Turbo Stream for a
# page refresh will be broadcasted to all clients subscribed to the "boards" stream.
#
# This works great in hierarchical structures, where the child record touches parent records automatically
# to invalidate the cache:
#
#   class Column < ApplicationRecord
#     belongs_to :board, touch: true # +Board+ will trigger a page refresh on column changes
#   end
#
# You can also specify the streamable declaratively by passing a symbol to the +broadcasts_refreshes_to+ method:
#
#   class Column < ApplicationRecord
#     belongs_to :board
#     broadcasts_refreshes_to :board
#   end
#
# For more granular control, you can also broadcast a "page refresh" to a stream name derived
# from the passed <tt>streamables</tt> by using the instance-level methods <tt>broadcast_refresh_to</tt> or
# <tt>broadcast_refresh_later_to</tt>. These methods are particularly useful when you want to trigger
# a page refresh for more specific scenarios. Example:
#
#   class Clearance < ApplicationRecord
#     belongs_to :petitioner, class_name: "Contact"
#     belongs_to :examiner,   class_name: "User"
#
#     after_create_commit :broadcast_refresh_later
#
#     private
#       def broadcast_refresh_later
#         broadcast_refresh_later_to examiner.identity, :clearances
#       end
#   end
#
# In this example, a "page refresh" is broadcast to the stream named "identity:<identity-id>:clearances"
# after a new clearance is created. All clients subscribed to this stream will refresh the page to reflect
# the changes.
#
# When broadcasting page refreshes, Turbo will automatically debounce multiple calls in a row to only broadcast the last one.
# This is meant for scenarios where you process records in mass. Because of the nature of such signals, it makes no sense to
# broadcast them repeatedly and individually.
# == Suppressing broadcasts
#
# Sometimes, you need to disable broadcasts in certain scenarios. You can use <tt>.suppressing_turbo_broadcasts</tt> to create
# execution contexts where broadcasts are disabled:
#
#   class Message < ApplicationRecord
#     after_create_commit :update_message
#
#     private
#       def update_message
#         broadcast_replace_to(user, :message, target: "message", renderable: MessageComponent.new)
#       end
#   end
#
#   Message.suppressing_turbo_broadcasts do
#     Message.create!(board: board) # This won't broadcast the replace action
#   end
module Turbo::Broadcastable
  extend ActiveSupport::Concern

  included do
    thread_mattr_accessor :suppressed_turbo_broadcasts, instance_accessor: false
    delegate :suppressed_turbo_broadcasts?, to: "self.class"
  end

  module ClassMethods
    # Configures the model to broadcast creates, updates, and destroys to a stream name derived at runtime by the
    # <tt>stream</tt> symbol invocation. By default, the creates are appended to a dom id target name derived from
    # the model's plural name. The insertion can also be made to be a prepend by overwriting <tt>inserts_by</tt> and
    # the target dom id overwritten by passing <tt>target</tt>. Examples:
    #
    #   class Message < ApplicationRecord
    #     belongs_to :board
    #     broadcasts_to :board
    #   end
    #
    #   class Message < ApplicationRecord
    #     belongs_to :board
    #     broadcasts_to ->(message) { [ message.board, :messages ] }, inserts_by: :prepend, target: "board_messages"
    #   end
    #
    #   class Message < ApplicationRecord
    #     belongs_to :board
    #     broadcasts_to ->(message) { [ message.board, :messages ] }, partial: "messages/custom_message"
    #   end
    def broadcasts_to(stream, inserts_by: :append, target: broadcast_target_default, **rendering)
      after_create_commit  -> { broadcast_action_later_to(stream.try(:call, self) || send(stream), action: inserts_by, target: target.try(:call, self) || target, **rendering) }
      after_update_commit  -> { broadcast_replace_later_to(stream.try(:call, self) || send(stream), **rendering) }
      after_destroy_commit -> { broadcast_remove_to(stream.try(:call, self) || send(stream)) }
    end

    # Same as <tt>#broadcasts_to</tt>, but the designated stream for updates and destroys is automatically set to
    # the current model, for creates - to the model plural name, which can be overriden by passing <tt>stream</tt>.
    def broadcasts(stream = model_name.plural, inserts_by: :append, target: broadcast_target_default, **rendering)
      after_create_commit  -> { broadcast_action_later_to(stream, action: inserts_by, target: target.try(:call, self) || target, **rendering) }
      after_update_commit  -> { broadcast_replace_later(**rendering) }
      after_destroy_commit -> { broadcast_remove }
    end

    # Configures the model to broadcast a "page refresh" on creates, updates, and destroys to a stream
    # name derived at runtime by the <tt>stream</tt> symbol invocation. Examples:
    #
    #   class Message < ApplicationRecord
    #     belongs_to :board
    #     broadcasts_refreshes_to :board
    #   end
    #
    #   class Message < ApplicationRecord
    #     belongs_to :board
    #     broadcasts_refreshes_to ->(message) { [ message.board, :messages ] }
    #   end
    def broadcasts_refreshes_to(stream)
      after_commit -> { broadcast_refresh_later_to(stream.try(:call, self) || send(stream)) }
    end

    # Same as <tt>#broadcasts_refreshes_to</tt>, but the designated stream for page refreshes is automatically set to
    # the current model, for creates - to the model plural name, which can be overriden by passing <tt>stream</tt>.
    def broadcasts_refreshes(stream = model_name.plural)
      after_create_commit  -> { broadcast_refresh_later_to(stream) }
      after_update_commit  -> { broadcast_refresh_later }
      after_destroy_commit -> { broadcast_refresh }
    end

    # All default targets will use the return of this method. Overwrite if you want something else than <tt>model_name.plural</tt>.
    def broadcast_target_default
      model_name.plural
    end

    # Executes +block+ preventing both synchronous and asynchronous broadcasts from this model.
    def suppressing_turbo_broadcasts(&block)
      original, self.suppressed_turbo_broadcasts = self.suppressed_turbo_broadcasts, true
      yield
    ensure
      self.suppressed_turbo_broadcasts = original
    end

    def suppressed_turbo_broadcasts?
      suppressed_turbo_broadcasts
    end
  end

  # Remove this broadcastable model from the dom for subscribers of the stream name identified by the passed streamables.
  # Example:
  #
  #   # Sends <turbo-stream action="remove" target="clearance_5"></turbo-stream> to the stream named "identity:2:clearances"
  #   clearance.broadcast_remove_to examiner.identity, :clearances
  def broadcast_remove_to(*streamables, target: self, **rendering)
    Turbo::StreamsChannel.broadcast_remove_to(*streamables, **extract_options_and_add_target(rendering, target: target)) unless suppressed_turbo_broadcasts?
  end

  # Same as <tt>#broadcast_remove_to</tt>, but the designated stream is automatically set to the current model.
  def broadcast_remove(**rendering)
    broadcast_remove_to self, **rendering
  end

  # Replace this broadcastable model in the dom for subscribers of the stream name identified by the passed
  # <tt>streamables</tt>. The rendering parameters can be set by appending named arguments to the call. Examples:
  #
  #   # Sends <turbo-stream action="replace" target="clearance_5"><template><div id="clearance_5">My Clearance</div></template></turbo-stream>
  #   # to the stream named "identity:2:clearances"
  #   clearance.broadcast_replace_to examiner.identity, :clearances
  #
  #   # Sends <turbo-stream action="replace" target="clearance_5"><template><div id="clearance_5">Other partial</div></template></turbo-stream>
  #   # to the stream named "identity:2:clearances"
  #   clearance.broadcast_replace_to examiner.identity, :clearances, partial: "clearances/other_partial", locals: { a: 1 }
  #
  #   # Sends <turbo-stream action="replace" method="morph" target="clearance_5"><template><div id="clearance_5">Other partial</div></template></turbo-stream>
  #   # to the stream named "identity:2:clearances"
  #   clearance.broadcast_replace_to examiner.identity, :clearance, attributes: { method: :morph }, partial: "clearances/other_partial", locals: { a: 1 }
  def broadcast_replace_to(*streamables, **rendering)
    Turbo::StreamsChannel.broadcast_replace_to(*streamables, **extract_options_and_add_target(rendering, target: self)) unless suppressed_turbo_broadcasts?
  end

  # Same as <tt>#broadcast_replace_to</tt>, but the designated stream is automatically set to the current model.
  def broadcast_replace(**rendering)
    broadcast_replace_to self, **rendering
  end

  # Update this broadcastable model in the dom for subscribers of the stream name identified by the passed
  # <tt>streamables</tt>. The rendering parameters can be set by appending named arguments to the call. Examples:
  #
  #   # Sends <turbo-stream action="update" target="clearance_5"><template><div id="clearance_5">My Clearance</div></template></turbo-stream>
  #   # to the stream named "identity:2:clearances"
  #   clearance.broadcast_update_to examiner.identity, :clearances
  #
  #   # Sends <turbo-stream action="update" target="clearance_5"><template><div id="clearance_5">Other partial</div></template></turbo-stream>
  #   # to the stream named "identity:2:clearances"
  #   clearance.broadcast_update_to examiner.identity, :clearances, partial: "clearances/other_partial", locals: { a: 1 }
  #
  #   # sends <turbo-stream action="update" method="morph" target="clearance_5"><template><div id="clearance_5">Other partial</div></template></turbo-stream>
  #   # to the stream named "identity:2:clearances"
  #   clearance.broadcast_update_to examiner.identity, :clearances, attributes: { method: :morph }, partial: "clearances/other_partial", locals: { a: 1 }
  def broadcast_update_to(*streamables, **rendering)
    Turbo::StreamsChannel.broadcast_update_to(*streamables, **extract_options_and_add_target(rendering, target: self)) unless suppressed_turbo_broadcasts?
  end

  # Same as <tt>#broadcast_update_to</tt>, but the designated stream is automatically set to the current model.
  def broadcast_update(**rendering)
    broadcast_update_to self, **rendering
  end

  # Insert a rendering of this broadcastable model before the target identified by it's dom id passed as <tt>target</tt>
  # for subscribers of the stream name identified by the passed <tt>streamables</tt>. The rendering parameters can be set by
  # appending named arguments to the call. Examples:
  #
  #   # Sends <turbo-stream action="before" target="clearance_5"><template><div id="clearance_4">My Clearance</div></template></turbo-stream>
  #   # to the stream named "identity:2:clearances"
  #   clearance.broadcast_before_to examiner.identity, :clearances, target: "clearance_5"
  #
  #   # Sends <turbo-stream action="before" target="clearance_5"><template><div id="clearance_4">Other partial</div></template></turbo-stream>
  #   # to the stream named "identity:2:clearances"
  #   clearance.broadcast_before_to examiner.identity, :clearances, target: "clearance_5",
  #     partial: "clearances/other_partial", locals: { a: 1 }
  def broadcast_before_to(*streamables, target: nil, targets: nil, **rendering)
    raise ArgumentError, "at least one of target or targets is required" unless target || targets

    Turbo::StreamsChannel.broadcast_before_to(*streamables, **extract_options_and_add_target(rendering.merge(target: target, targets: targets))) unless suppressed_turbo_broadcasts?
  end

  # Insert a rendering of this broadcastable model after the target identified by it's dom id passed as <tt>target</tt>
  # for subscribers of the stream name identified by the passed <tt>streamables</tt>. The rendering parameters can be set by
  # appending named arguments to the call. Examples:
  #
  #   # Sends <turbo-stream action="after" target="clearance_5"><template><div id="clearance_6">My Clearance</div></template></turbo-stream>
  #   # to the stream named "identity:2:clearances"
  #   clearance.broadcast_after_to examiner.identity, :clearances, target: "clearance_5"
  #
  #   # Sends <turbo-stream action="after" target="clearance_5"><template><div id="clearance_6">Other partial</div></template></turbo-stream>
  #   # to the stream named "identity:2:clearances"
  #   clearance.broadcast_after_to examiner.identity, :clearances, target: "clearance_5",
  #     partial: "clearances/other_partial", locals: { a: 1 }
  def broadcast_after_to(*streamables, target: nil, targets: nil, **rendering)
    raise ArgumentError, "at least one of target or targets is required" unless target || targets

    Turbo::StreamsChannel.broadcast_after_to(*streamables, **extract_options_and_add_target(rendering.merge(target: target, targets: targets))) unless suppressed_turbo_broadcasts?
  end

  # Append a rendering of this broadcastable model to the target identified by it's dom id passed as <tt>target</tt>
  # for subscribers of the stream name identified by the passed <tt>streamables</tt>. The rendering parameters can be set by
  # appending named arguments to the call. Examples:
  #
  #   # Sends <turbo-stream action="append" target="clearances"><template><div id="clearance_5">My Clearance</div></template></turbo-stream>
  #   # to the stream named "identity:2:clearances"
  #   clearance.broadcast_append_to examiner.identity, :clearances, target: "clearances"
  #
  #   # Sends <turbo-stream action="append" target="clearances"><template><div id="clearance_5">Other partial</div></template></turbo-stream>
  #   # to the stream named "identity:2:clearances"
  #   clearance.broadcast_append_to examiner.identity, :clearances, target: "clearances",
  #     partial: "clearances/other_partial", locals: { a: 1 }
  def broadcast_append_to(*streamables, target: broadcast_target_default, **rendering)
    Turbo::StreamsChannel.broadcast_append_to(*streamables, **extract_options_and_add_target(rendering, target: target)) unless suppressed_turbo_broadcasts?
  end

  # Same as <tt>#broadcast_append_to</tt>, but the designated stream is automatically set to the current model.
  def broadcast_append(target: broadcast_target_default, **rendering)
    broadcast_append_to self, target: target, **rendering
  end

  # Prepend a rendering of this broadcastable model to the target identified by it's dom id passed as <tt>target</tt>
  # for subscribers of the stream name identified by the passed <tt>streamables</tt>. The rendering parameters can be set by
  # appending named arguments to the call. Examples:
  #
  #   # Sends <turbo-stream action="prepend" target="clearances"><template><div id="clearance_5">My Clearance</div></template></turbo-stream>
  #   # to the stream named "identity:2:clearances"
  #   clearance.broadcast_prepend_to examiner.identity, :clearances, target: "clearances"
  #
  #   # Sends <turbo-stream action="prepend" target="clearances"><template><div id="clearance_5">Other partial</div></template></turbo-stream>
  #   # to the stream named "identity:2:clearances"
  #   clearance.broadcast_prepend_to examiner.identity, :clearances, target: "clearances",
  #     partial: "clearances/other_partial", locals: { a: 1 }
  def broadcast_prepend_to(*streamables, target: broadcast_target_default, **rendering)
    Turbo::StreamsChannel.broadcast_prepend_to(*streamables, **extract_options_and_add_target(rendering, target: target)) unless suppressed_turbo_broadcasts?
  end

  # Same as <tt>#broadcast_prepend_to</tt>, but the designated stream is automatically set to the current model.
  def broadcast_prepend(target: broadcast_target_default, **rendering)
    broadcast_prepend_to self, target: target, **rendering
  end

  #  Broadcast a "page refresh" to the stream name identified by the passed <tt>streamables</tt>. Example:
  #
  #   # Sends <turbo-stream action="refresh"></turbo-stream> to the stream named "identity:2:clearances"
  #   clearance.broadcast_refresh_to examiner.identity, :clearances
  def broadcast_refresh_to(*streamables, **attributes)
    Turbo::StreamsChannel.broadcast_refresh_to(*streamables, **attributes) unless suppressed_turbo_broadcasts?
  end

  #  Same as <tt>#broadcast_refresh_to</tt>, but the designated stream is automatically set to the current model.
  def broadcast_refresh
    broadcast_refresh_to self
  end

  # Broadcast a named <tt>action</tt>, allowing for dynamic dispatch, instead of using the concrete action methods. Examples:
  #
  #   # Sends <turbo-stream action="prepend" target="clearances"><template><div id="clearance_5">My Clearance</div></template></turbo-stream>
  #   # to the stream named "identity:2:clearances"
  #   clearance.broadcast_action_to examiner.identity, :clearances, action: :prepend, target: "clearances"
  def broadcast_action_to(*streamables, action:, target: broadcast_target_default, attributes: {}, **rendering)
    Turbo::StreamsChannel.broadcast_action_to(*streamables, action: action, attributes: attributes, **extract_options_and_add_target(rendering, target: target)) unless suppressed_turbo_broadcasts?
  end

  # Same as <tt>#broadcast_action_to</tt>, but the designated stream is automatically set to the current model.
  def broadcast_action(action, target: broadcast_target_default, attributes: {}, **rendering)
    broadcast_action_to self, action: action, target: target, attributes: attributes, **rendering
  end

  # Same as <tt>broadcast_replace_to</tt> but run asynchronously via a <tt>Turbo::Streams::BroadcastJob</tt>.
  def broadcast_replace_later_to(*streamables, **rendering)
    Turbo::StreamsChannel.broadcast_replace_later_to(*streamables, **extract_options_and_add_target(rendering, target: self)) unless suppressed_turbo_broadcasts?
  end

  # Same as <tt>#broadcast_replace_later_to</tt>, but the designated stream is automatically set to the current model.
  def broadcast_replace_later(**rendering)
    broadcast_replace_later_to self, **rendering
  end

  # Same as <tt>broadcast_update_to</tt> but run asynchronously via a <tt>Turbo::Streams::BroadcastJob</tt>.
  def broadcast_update_later_to(*streamables, **rendering)
    Turbo::StreamsChannel.broadcast_update_later_to(*streamables, **extract_options_and_add_target(rendering, target: self)) unless suppressed_turbo_broadcasts?
  end

  # Same as <tt>#broadcast_update_later_to</tt>, but the designated stream is automatically set to the current model.
  def broadcast_update_later(**rendering)
    broadcast_update_later_to self, **rendering
  end

  # Same as <tt>broadcast_append_to</tt> but run asynchronously via a <tt>Turbo::Streams::BroadcastJob</tt>.
  def broadcast_append_later_to(*streamables, target: broadcast_target_default, **rendering)
    Turbo::StreamsChannel.broadcast_append_later_to(*streamables, **extract_options_and_add_target(rendering, target: target)) unless suppressed_turbo_broadcasts?
  end

  # Same as <tt>#broadcast_append_later_to</tt>, but the designated stream is automatically set to the current model.
  def broadcast_append_later(target: broadcast_target_default, **rendering)
    broadcast_append_later_to self, target: target, **rendering
  end

  # Same as <tt>broadcast_prepend_to</tt> but run asynchronously via a <tt>Turbo::Streams::BroadcastJob</tt>.
  def broadcast_prepend_later_to(*streamables, target: broadcast_target_default, **rendering)
    Turbo::StreamsChannel.broadcast_prepend_later_to(*streamables, **extract_options_and_add_target(rendering, target: target)) unless suppressed_turbo_broadcasts?
  end

  # Same as <tt>#broadcast_prepend_later_to</tt>, but the designated stream is automatically set to the current model.
  def broadcast_prepend_later(target: broadcast_target_default, **rendering)
    broadcast_prepend_later_to self, target: target, **rendering
  end

  #  Same as <tt>broadcast_refresh_to</tt> but run asynchronously via a <tt>Turbo::Streams::BroadcastJob</tt>.
  def broadcast_refresh_later_to(*streamables, **attributes)
    Turbo::StreamsChannel.broadcast_refresh_later_to(*streamables, request_id: Turbo.current_request_id, **attributes) unless suppressed_turbo_broadcasts?
  end

  #  Same as <tt>#broadcast_refresh_later_to</tt>, but the designated stream is automatically set to the current model.
  def broadcast_refresh_later
    broadcast_refresh_later_to self
  end

  # Same as <tt>broadcast_action_to</tt> but run asynchronously via a <tt>Turbo::Streams::BroadcastJob</tt>.
  def broadcast_action_later_to(*streamables, action:, target: broadcast_target_default, attributes: {}, **rendering)
    Turbo::StreamsChannel.broadcast_action_later_to(*streamables, action: action, attributes: attributes, **extract_options_and_add_target(rendering, target: target)) unless suppressed_turbo_broadcasts?
  end

  # Same as <tt>#broadcast_action_later_to</tt>, but the designated stream is automatically set to the current model.
  def broadcast_action_later(action:, target: broadcast_target_default, attributes: {}, **rendering)
    broadcast_action_later_to self, action: action, target: target, attributes: attributes, **rendering
  end

  # Render a turbo stream template with this broadcastable model passed as the local variable. Example:
  #
  #   # Template: entries/_entry.turbo_stream.erb
  #   <%= turbo_stream.remove entry %>
  #
  #   <%= turbo_stream.append "entries", entry if entry.active? %>
  #
  # Sends:
  #
  #   <turbo-stream action="remove" target="entry_5"></turbo-stream>
  #   <turbo-stream action="append" target="entries"><template><div id="entry_5">My Entry</div></template></turbo-stream>
  #
  # ...to the stream named "entry:5".
  #
  # Note that rendering inline via this method will cause template rendering to happen synchronously. That is usually not
  # desireable for model callbacks, certainly not if those callbacks are inside of a transaction. Most of the time you should
  # be using +broadcast_render_later+, unless you specifically know why synchronous rendering is needed.
  def broadcast_render(**rendering)
    broadcast_render_to self, **rendering
  end

  # Same as <tt>broadcast_render</tt> but run with the added option of naming the stream using the passed
  # <tt>streamables</tt>.
  #
  # Note that rendering inline via this method will cause template rendering to happen synchronously. That is usually not
  # desireable for model callbacks, certainly not if those callbacks are inside of a transaction. Most of the time you should
  # be using +broadcast_render_later_to+, unless you specifically know why synchronous rendering is needed.
  def broadcast_render_to(*streamables, **rendering)
    Turbo::StreamsChannel.broadcast_render_to(*streamables, **extract_options_and_add_target(rendering, target: self)) unless suppressed_turbo_broadcasts?
  end

  # Same as <tt>broadcast_render_to</tt> but run asynchronously via a <tt>Turbo::Streams::BroadcastJob</tt>.
  def broadcast_render_later(**rendering)
    broadcast_render_later_to self, **rendering
  end

  # Same as <tt>broadcast_render_later</tt> but run with the added option of naming the stream using the passed
  # <tt>streamables</tt>.
  def broadcast_render_later_to(*streamables, **rendering)
    Turbo::StreamsChannel.broadcast_render_later_to(*streamables, **extract_options_and_add_target(rendering)) unless suppressed_turbo_broadcasts?
  end

  private
    def broadcast_target_default
      self.class.broadcast_target_default
    end

    def extract_options_and_add_target(rendering = {}, target: broadcast_target_default)
      broadcast_rendering_with_defaults(rendering).tap do |options|
        options[:target] = target if !options.key?(:target) && !options.key?(:targets)
      end
    end

    def broadcast_rendering_with_defaults(options)
      options.tap do |o|
        # Add the current instance into the locals with the element name (which is the un-namespaced name)
        # as the key. This parallels how the ActionView::ObjectRenderer would create a local variable.
        o[:locals] = (o[:locals] || {}).reverse_merge(model_name.element.to_sym => self)

        if o[:html] || o[:partial]
          return o
        elsif o[:template] || o[:renderable]
          o[:layout] = false
        elsif o[:render] == false
          return o
        else
          # if none of these options are passed in, it will set a partial from #to_partial_path
          o[:partial] ||= to_partial_path
        end
      end
    end
end
```
