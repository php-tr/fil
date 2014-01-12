package org.phptr.philip;

import android.content.Intent;
import android.net.Uri;
import com.artifex.mupdfdemo.MuPDFActivity;
import org.qtproject.qt5.android.bindings.QtActivity;

public class PdfReaderActivity extends QtActivity
{
    public PdfReaderActivity()
    {
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
