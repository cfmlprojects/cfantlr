package cfantlr;
import java.lang.reflect.Array;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;

public class RailoListener extends BaseErrorListener {
    private static final boolean REPORT_SYNTAX_ERRORS = true;
	public static RailoListener INSTANCE = new RailoListener();
	private Object listener;
	private Object pc;
	private ClassLoader classloader;

	public void setListener(Object listener) {
		try {
			this.classloader = listener.getClass().getClassLoader();
			try {
				Class instance = classloader.loadClass("railo.loader.engine.CFMLEngineFactory");
				Class instanceImpl = classloader.loadClass("railo.loader.engine.CFMLEngine");
				Method getInstance = instance.getMethod("getInstance",new Class[] { });
				Method getThreadPageContext = instanceImpl.getMethod("getThreadPageContext",new Class[] { });
				Object engine = getInstance.invoke(instance,new Object[] {});
				this.pc = getThreadPageContext.invoke(engine,new Object[] {});
				//System.err.println(sourceName+"line "+line+":"+charPositionInLine+" "+msg);
			} catch (Exception er) {
				// TODO Auto-generated catch block
				er.printStackTrace();
			}
			this.listener = listener;
		} catch (Exception er) {
			// TODO Auto-generated catch block
			er.printStackTrace();
		}
	}

    @Override
    public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol,
                            int line, int charPositionInLine,
                            String msg, RecognitionException e)
    {
    	String sourceName = recognizer.getInputStream().getSourceName();
    	if (sourceName != null && !sourceName.isEmpty()) {
    		sourceName = String.format("%s:%d:%d: ", sourceName, line, charPositionInLine);
    	} else {
    		sourceName="";
    	}
    	if (!REPORT_SYNTAX_ERRORS) {
    		return;
    	}
		try {
			Class component = classloader.loadClass("railo.runtime.ComponentImpl");
			Class PageContext = classloader.loadClass("railo.runtime.PageContext");
			Class PageException = classloader.loadClass("railo.runtime.exp.PageException");
			Method call = component.getMethod("call",new Class[] { PageContext, String.class, Object[].class });
			try {
				call.invoke(listener,new Object[] { pc, "syntaxError", new Object[]{recognizer, offendingSymbol, line, charPositionInLine, msg, sourceName, e}});
			} catch ( IllegalArgumentException cause ) {
			     // reflection exception
			}
			catch ( NullPointerException cause )
			{
			     // reflection exception
			}
			catch ( InvocationTargetException cause )
			{
			     try
			     {
						System.out.println("CAUSE");
			           throw cause . getCause ( ) ;
			     }
			     catch ( IllegalArgumentException c )
			     {
			           // method exception
			     }
			     catch ( NullPointerException c )
			     {
			            //method exception
			     } catch (Throwable e1) {
					// TODO Auto-generated catch block
						System.out.println("THROWABLE");
					e1.printStackTrace();
				}
			}
			//System.err.println(sourceName+"line "+line+":"+charPositionInLine+" "+msg);
		} catch (Exception er) {
			// TODO Auto-generated catch block
			System.out.println("ENDCATCH");
			er.printStackTrace();
			er.printStackTrace();
		}
    }
}