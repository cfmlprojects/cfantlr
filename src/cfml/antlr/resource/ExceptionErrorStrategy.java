package cfantlr;

import org.antlr.v4.runtime.DefaultErrorStrategy;
import org.antlr.v4.runtime.InputMismatchException;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.Parser;
import org.antlr.v4.runtime.misc.IntervalSet;

public class ExceptionErrorStrategy extends DefaultErrorStrategy {

    @Override
    public void recover(Parser recognizer, RecognitionException e) {
        throw e;
    }

    @Override
    public void reportInputMismatch(Parser recognizer, InputMismatchException e) throws RecognitionException {
        String msg = "mismatched input " + getTokenErrorDisplay(e.getOffendingToken());
        msg += " expecting one of "+e.getExpectedTokens().toString(recognizer.getTokenNames());
        RecognitionException ex = new RecognitionException(msg, recognizer, recognizer.getInputStream(), recognizer.getContext());
        ex.initCause(e);
        throw ex;
    }

    @Override
    public void reportMissingToken(Parser recognizer) {
        beginErrorCondition(recognizer);
        Token t = recognizer.getCurrentToken();
        IntervalSet expecting = getExpectedTokens(recognizer);
        String msg = "missing "+expecting.toString(recognizer.getTokenNames()) + " at " + getTokenErrorDisplay(t);
        throw new RecognitionException(msg, recognizer, recognizer.getInputStream(), recognizer.getContext());
    }
    
    @Override
    public void reportUnwantedToken(Parser recognizer) {
    	if (inErrorRecoveryMode(recognizer)) {
			return;
		}
		beginErrorCondition(recognizer);
		Token t = recognizer.getCurrentToken();
		String tokenName = getTokenErrorDisplay(t);
		System.out.println(recognizer.getRuleIndexMap());
		System.out.println(recognizer.getRuleInvocationStack());
		Integer name = recognizer.getRuleContext().getRuleIndex();
		IntervalSet expecting = getExpectedTokens(recognizer);
		String msg = "unknown SS "+name +tokenName+" expecting "+
			expecting.toString(recognizer.getTokenNames());
		recognizer.notifyErrorListeners(t, msg, null);
	}
}