package org.phptr.philip;

import android.app.AlertDialog;
import android.content.DialogInterface;
import org.qtproject.qt5.android.bindings.QtActivity;

public class MainActivity extends QtActivity
{
    private static MainActivity _instance = null;

    public MainActivity()
    {
        _instance = this;
    }

    public static MainActivity getInstance()
    {
        return _instance;
    }

    public static void confirmDownload(final int magazineId)
    {
        _instance.runOnUiThread(new Runnable()
        {
            @Override
            public void run()
            {
                new AlertDialog.Builder(_instance)
                        .setTitle("Download Confirmation")
                        .setIcon(android.R.drawable.ic_dialog_alert)
                        .setMessage("Are you sure to download magazine?")
                        .setPositiveButton(
                                "Download",
                                new DialogInterface.OnClickListener()
                                {
                                    @Override
                                    public void onClick(DialogInterface dialogInterface, int i)
                                    {
                                        downloadConfirmed(magazineId);
                                    }
                                }
                        )
                        .setNegativeButton(
                                "Cancel",
                                new DialogInterface.OnClickListener()
                                {
                                    @Override
                                    public void onClick(DialogInterface dialogInterface, int i)
                                    {

                                    }
                                }
                        )
                        .show();
            }
        });
    }

    public static native void downloadConfirmed(int magazineId);
}
