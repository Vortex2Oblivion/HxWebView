package webview;

import webview.internal.WVExterns;
import webview.internal.WVTypes;

// Wrapper class for the externs
class WebView
{
    private var handle:Null<WindowPtr> = null;

    /**
     * Creates a new webview instance.
     * 
     * Depending on the platform, a GtkWindow, NSWindow or HWND pointer can be
     * passed on the window argument. 
     * 
     * Creation can fail for various reasons
     * such as when required runtime dependencies are missing or when window creation
     * fails.
     * 
     * @param debug If true, developer tools will be enabled (if the platform supports them).
     * @param window [Pointer to the native window handle (NOT WORKING)] If a pointer is passed, then child webview will be embedded into the given parent window, otherwise a new window is created.
     */
    public function new(debug:Bool = false, ?window:WindowPtr)
    {
        handle = WVExterns.webview_create(debug ? 1 : 0, window);

        if (handle == null)
        {
            trace('Failed to create a WebView');
            return;
        }
    }

    /**
     * Destroys a webview and closes the native window.
     */
    public function destroy():Void
    {
        if (handle == null)
            return;

        WVExterns.webview_destroy(handle);
    }

    /**
     * Runs the main loop until it's terminated.
     * 
     * After this function exits you must destroy the webview.
     */
    public function run():Void
    {
        if (handle == null)
            return;

        WVExterns.webview_run(handle);
    }

    /**
     * Stops the main loop.
     * 
     * It is safe to call this function from another thread.
     */
    public function terminate():Void
    {
        if (handle == null)
            return;

        WVExterns.webview_terminate(handle);
    }

    /**
     * Posts a function to be executed on the main thread.
     * 
     * You normally do not need to call this function, unless you want to tweak the native window.
     */
    public function dispatch(fn:DispatchFunc, arg:Dynamic):Void
    {
        if (handle == null)
            return;

        WVExterns.webview_dispatch(handle, fn, arg);
    }

    /**
     * Returns a native window handle pointer.
     * 
     * When using a GTK backend the pointer is a GtkWindow pointer.
     * 
     * When using a Cocoa backend the pointer is a NSWindow pointer.
     * 
     * When using a Win32 backend the pointer is a HWND pointer.
     */
    public function getWindow():WindowPtr
    {
        if (handle == null)
            return null;

        return WVExterns.webview_get_window(handle);
    }

    /**
     * Updates the title of the native window.
     * 
     * Must be called from the UI thread.
     */
    public function setTitle(title:String):Void
    {
        if (handle == null)
            return;

        WVExterns.webview_set_title(handle, title);
    }

    /**
     * Updates the size of the native window.
     * 
     * See WebViewSizeHint enum.
     */
    public function setSize(width:Int, height:Int, hints:WebViewSizeHint):Void
    {
        if (handle == null || width <= 0 && height <= 0)
            return;

        WVExterns.webview_set_size(handle, width, height, hints);
    }

    /**
     * Navigates webview to the given URL.
     * 
     * URL may be a properly encoded data URI.
     * 
     * Example:
     * 
     * ```haxe
     * var webview:WebView = new WebView();
     * webview.navigate("https://github.com/webview/webview");
     * webview.navigate("data:text/html,%3Ch1%3EHello%3C%2Fh1%3E");
     * webview.navigate("data:text/html;base64,PGgxPkhlbGxvPC9oMT4=");
     * ```
     */
    public function navigate(url:String):Void
    {
        if (handle == null)
            return;

        WVExterns.webview_navigate(handle, url);
    }

    /**
     * Set webview HTML directly.
     * 
     * Example:
     * 
     * ```haxe
     * var webview:WebView = new WebView();
     * webview.setHTML("<h1>Hello</h1>");
     * ```
     */
    public function setHTML(html:String):Void
    {
        if (handle == null)
            return;

        WVExterns.webview_set_html(handle, html);
    }

    /**
     * Injects JavaScript code at the initialization of the new page.
     * 
     * Every time the webview will open a new page, this initialization code will be executed.
     * 
     * It is guaranteed that the code is executed before window.onload.
     */
    public function init(js:String):Void
    {
        if (handle == null)
            return;

        WVExterns.webview_init(handle, js);
    }

    /**
     * Evaluates arbitrary JavaScript code.
     * 
     * Evaluation happens asynchronously, also the result of the expression is ignored.
     * 
     * Use RPC bindings if you want to receive notifications about the results of the evaluation.
     */
    public function eval(js:String):Void
    {
        if (handle == null)
            return;

        WVExterns.webview_eval(handle, js);
    }

    /**
     * Binds a native Haxe callback so that it will appear under the given name as a global JavaScript function.
     * 
     * Internally it uses webview.init().
     * 
     * The callback receives a sequential request id, a request string and a user-provided argument pointer.
     * 
     * The request string is a JSON array of all the arguments passed to the JavaScript function.
     */
    public function bind(name:String, fn:BindFunc, arg:Dynamic):Void
    {
        if (handle == null)
            return;

        WVExterns.webview_bind(handle, name, fn, arg);
    }

    /**
     * Removes a native Haxe callback that was previously set by webview.bind
     */
    public function unbind(name:String):Void
    {
        if (handle == null)
            return;

        WVExterns.webview_unbind(handle, name);
    }

    /**
     * Responds to a binding call from the JavaScript side.
     * 
     * The ID/sequence number must match the value passed to the binding handler
     * in order to respond to the call and complete the promise on the JavaScript side.
     * 
     * A status of zero resolves the promise, and any other value rejects it.
     * 
     * The result must either be a valid JSON value or an empty string for the primitive JS value "undefined".
     */
    public function resolve(seq:String, status:Int, result:String):Void
    {
        if (handle == null)
            return;

        WVExterns.webview_return(handle, seq, status, result);
    }

    /**
     * Get the library's version information.
     * @since 0.10
     */
    public static function version():WebViewInfo
        return WVExterns.webview_version();

    /**
     * Used to get the Main Window from the current process.
     * 
     * This behaves almost like webview.getWindow() if the WebView is a standalone Window.
     */
    public static function getMainWindow():WindowPtr
        return WVExterns.find_main_window();
}