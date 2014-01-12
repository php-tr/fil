package org.phptr.philip;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.Bundle;
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
                        .setTitle(R.string.download_confirmation)
                        .setIcon(android.R.drawable.ic_dialog_alert)
                        .setMessage(R.string.are_you_sure_to_download)
                        .setPositiveButton(
                                R.string.download,
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
                                R.string.cancel,
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
