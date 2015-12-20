package org.phptr.fil;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import com.artifex.mupdfdemo.MuPDFActivity;

public class PdfReaderController
{
    private final Activity m_activity;

    public PdfReaderController(final Activity activity)
    {
        m_activity = activity;
    }

    public void openPdf(final String pdfPath)
    {
        try {
            Intent intent = new Intent(m_activity, MuPDFActivity.class);
            intent.setAction(Intent.ACTION_VIEW);
            intent.setData(Uri.parse(pdfPath));

            m_activity.startActivity(intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
