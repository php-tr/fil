package org.phptr.philip;

import android.content.Intent;
import android.net.Uri;
import android.os.Handler;
import com.artifex.mupdfdemo.MuPDFActivity;
import org.qtproject.qt5.android.bindings.QtActivity;
import android.content.res.Resources;

public class PdfReaderActivity extends QtActivity
{
    private static PdfReaderActivity _instance;

    private Handler  _handler;
    private Runnable     _updateFiles;

    public PdfReaderActivity()
    {
        _instance = this;

        _handler = new Handler();
        _updateFiles = new Runnable()
        {
            public void run()
            {
                Resources res = getResources();
            }
        };
        _handler.post(_updateFiles);
    }

    public static void openPdf(final String pdfPath)
    {
        try
        {
            Intent intent = new Intent(MainActivity.getInstance(), MuPDFActivity.class);
            intent.setAction(Intent.ACTION_VIEW);
            intent.setData(Uri.parse(pdfPath));

            MainActivity.getInstance().startActivity(intent);
        }
        catch (Exception e)
        {
            e.printStackTrace();;
        }
    }
}
